
# UPDATE Message Format
#  
#     UPDATE messages are used to transfer routing information between BGP
#     peers.  The information in the UPDATE message can be used to
#     construct a graph that describes the relationships of the various
#     Autonomous Systems.  By applying rules to be discussed, routing
#  
#  
#  
#  Rekhter, et al.             Standards Track                    [Page 14]
#  
#  RFC 4271                         BGP-4                      January 2006
#  
#  
#     information loops and some other anomalies may be detected and
#     removed from inter-AS routing.
#  
#     An UPDATE message is used to advertise feasible routes that share
#     common path Copyright 2008, 2009 to a peer, or to withdraw multiple unfeasible
#     routes from service (see 3.1).  An UPDATE message MAY simultaneously
#     advertise a feasible route and withdraw multiple unfeasible routes
#     from service.  The UPDATE message always includes the fixed-size BGP
#     header, and also includes the other fields, as shown below (note,
#     some of the shown fields may not be present in every UPDATE message):
#  
#        +-----------------------------------------------------+
#        |   Withdrawn Routes Length (2 octets)                |
#        +-----------------------------------------------------+
#        |   Withdrawn Routes (variable)                       |
#        +-----------------------------------------------------+
#        |   Total Path Attribute Length (2 octets)            |
#        +-----------------------------------------------------+
#        |   Path Attributes (variable)                        |
#        +-----------------------------------------------------+
#        |   Network Layer Reachability Information (variable) |
#        +-----------------------------------------------------+
#  

require 'bgp/messages/message'
require 'bgp/path_attributes/path_attribute'

class BGP::Update < BGP::Message
  include BGP
  
  class Info
    def initialize(*args)
      @as4byte=args[0]
    end
    def as4byte?
      @as4byte
    end
    def recv_inet_unicast?
      false
    end
  end

  def initialize(*args)
    @nlri, @path_attribute, @withdrawn=nil,nil,nil
    @session_info = Info.new
    if args[0].is_a?(String) and args[0].is_packed?
      if args.size==1
        parse args[0], @session_info
      else
        parse(*args)
      end
    elsif args[0].is_a?(self.class)
      parse(args[0].encode, *args[1..-1])
    else
      @msg_type=UPDATE
      set(*args)
    end
  end

  def set(*args)
    args.each { |arg|
      if arg.is_a?(Withdrawn)
        self.withdrawn=arg
      elsif arg.is_a?(Path_attribute)
        self.path_attribute = arg
      elsif arg.is_a?(Nlri)
        self.nlri = arg
        # FIXME
      # elsif arg.is_a?(Ext_Nlri)
      #   self.nlri = arg
      end
    }
  end

  def session_info=(val)
    @session_info=val
    raise unless val.respond_to? :as4byte?
  end

  def withdrawn=(val)
    @withdrawn=val if val.is_a?(Withdrawn)
  end

  def nlri=(val)
    @nlri=val if val.is_a?(Nlri) or val.is_a?(Ext_Nlri)
  end

  def path_attribute=(val)
    @path_attribute=val if val.is_a?(Path_attribute)
  end

  def encode(session_info=@session_info)
    withdrawn, path_attribute, nlri = '', '', ''
    withdrawn = @withdrawn.encode if @withdrawn
    path_attribute = @path_attribute.encode(session_info.as4byte?) if @path_attribute
    super([withdrawn.size, withdrawn, path_attribute.size, path_attribute, encoded_nlri].pack('na*na*a*'))
  end

  def encode4()
    encode(Info.new(true))
  end

  attr_reader :path_attribute, :nlri, :withdrawn, :session_info

  def parse(s, session_info)
    update = super(s)

    len = update.slice!(0,2).unpack('n')[0]
    
    if len>0
      s = update.slice!(0,len)
      w =  Withdrawn.new_ntop(s,ext_nlri?(session_info))
      self.withdrawn= w
    end

    len = update.slice!(0,2).unpack('n')[0]
    if len>0
      enc_path_attribute = update.slice!(0,len).is_packed
      self.path_attribute=Path_attribute.new(enc_path_attribute, session_info)
    end

    self.nlri = Nlri.factory(update, 1, 1, ext_nlri?(session_info)) if update.size>0
    
  end
  
  def ext_nlri?(session_info)
    session_info and session_info.recv_inet_unicast?
  end

  def <<(val)
    if val.is_a?(Attr)
      @path_attribute ||= Path_attribute.new
      @path_attribute << val
    elsif val.is_a?(String)
      begin 
        # Nlri.new(val)
        @nlri ||=Nlri.new
        @nlri << val
      rescue => e
        p "JME: ***** #{val.inspect}"
        p e
        raise
      end
    elsif val.is_a?(Nlri)
      val.to_s.split.each { |n| self << n }
    else
      raise ArgmentError, "Invalid arg: #{val.inspect}"
    end
  end

  def to_s(session_info=@session_info)
    msg = encode(session_info)
    fmt=:tcpdump
    s = []
    if @withdrawn
      s << "Withdrawn Routes:"
      s << @withdrawn.to_s if @withdrawn
    end

    s << @path_attribute.to_s(fmt, session_info.as4byte?) if defined?(@path_attribute) and @path_attribute
    if @nlri
      s << "Network Layer Reachability Information:"
      s << @nlri.to_s
    end
    "Update Message (#{UPDATE}), #{session_info.as4byte? ? "4 bytes AS, " : ''}length: #{msg.size}\n" +
    s.join("\n") + "\n" + msg.hexlify.join("\n") + "\n"
  end

  def self.withdrawn(u)
    if u.nlri and u.nlri.size>0
      Update.new(Withdrawn.new(*(u.nlri.nlris.collect { |n| n.to_s})))
    elsif u.path_attribute.has?(Mp_reach)
      pa = Path_attribute.new
      pa << u.path_attribute[ATTR::MP_REACH].new_unreach
      Update.new(pa)
    end
  end

  def encoded_nlri
    @nlri.encode if @nlri
  end

end

#  JME
# include BGP
# 
# require 'bgp/path_attributes/attributes'
# 
# 
#  def ext_update(s)
#    sbin = [s.split.join].pack('H*')
#    o = Update::Info.new(true)
#    def o.path_id?(*args) ; true ; end
#    def o.recv_inet_unicast? ; true ; end
#    def o.send_inet_unicast? ; true ; end
#    Update.factory(sbin,o)
#  end
# 
# 
#  upd = ext_update "
#   ffff ffff ffff ffff ffff ffff ffff ffff
#   0031 0200 0000 1a90 0f00 1600 0180 0000
#   0001 7080 0001 0000 0001 0000 0001 0a01
#   01"
#   p upd.path_attribute.has_a_mp_unreach_attr?
#   p mp_unreach = upd.path_attribute[:mp_unreach]
#   puts mp_unreach
#   puts mp_unreach.to_shex

















# load "../../test/unit/messages/#{ File.basename($0.gsub(/.rb/,'_test.rb'))}" if __FILE__ == $0

#--
# Copyright 2008, 2009 Jean-Michel Esnault.
# All rights reserved.
# See LICENSE.txt for permissions.
#
#
# This file is part of BGP4R.
# 
# BGP4R is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# BGP4R is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with BGP4R.  If not, see <http://www.gnu.org/licenses/>.
#++

require 'test/unit'  
require 'bgp/nlris/prefix2'

class Prefix_Test < Test::Unit::TestCase
  include BGP
  def test_inet
    pfx =  Prefix.new('10.0.0.0')
    assert_equal('10.0.0.0/32', pfx.to_s)
    assert_equal('200a000000', pfx.to_shex)
    pfx =  Prefix.new('10.1.1.1/16')
    assert_equal('10.1.0.0/16', pfx.to_s)
    assert_equal('100a01', pfx.to_shex)
    pfx =  Prefix.new('10.255.255.255/17')
    assert_equal(17, pfx.mlen)
    assert_equal('10.255.128.0/17', pfx.to_s)
    assert_equal('110aff80', pfx.to_shex)
    assert   pfx.ipv4?
    assert ! pfx.ipv6?
    assert ! pfx.iso?
    assert_equal(1, pfx.afi)
    assert ! pfx.extended?
    assert_equal('IPv4=10.255.128.0/17', pfx.to_s_with_afi)
  end
  def test_extended
    pfx = Prefix.new(100, '10.0.0.0')
    assert pfx.extended?
    assert_equal('00000064200a000000', pfx.to_shex)
    assert_equal('ID=100, 10.0.0.0/32', pfx.to_s)
    pfx1 = Prefix.new_ntop_extended(pfx.encode)
    assert_equal(pfx.to_shex, pfx.to_shex)
    pfx = Prefix.new(100, '2011:13:11::0/64')
    assert pfx.extended?
    assert_equal('ID=100, 2011:13:11::/64', pfx.to_s)
    assert_equal('00000064402011001300110000', pfx.to_shex)
    assert_equal('ID=100, IPv6=2011:13:11::/64', pfx.to_s_with_afi)
    
  end
  def test_inet6
    pfx =  Prefix.new('2011:13:11::0/64')
    assert_equal('2011:13:11::/64', pfx.to_s)
    assert_equal(64, pfx.mlen)
    assert_equal('402011001300110000', pfx.to_shex)
    pfx =  Prefix.new('2011:13:11::0')
    assert_equal('2011:13:11::/128', pfx.to_s)
    assert_equal('8020110013001100000000000000000000', pfx.to_shex)
    assert ! pfx.ipv4?
    assert   pfx.ipv6?
    assert ! pfx.iso?
    assert_equal(2, pfx.afi)
    assert_equal('IPv6=2011:13:11::/128', pfx.to_s_with_afi)
  end
  def test_nsap

    #FIXME: 9849000100020003f15200000000000000000000 ??? what this 3f152 ....
    pfx =  Prefix.new('49.0001.0002.0003')
    assert_equal('9849000100020003000000000000000000000000', pfx.to_shex )
    assert_equal('49.0001.0002.0003.0000.0000.0000.0000.0000.0000.00/152', pfx.to_s)
    
    pfx =  Prefix.new('49.0001.0002.0003/32')
    assert_equal('2049000100', pfx.to_shex )
    assert_equal('49.0001.0000.0000.0000.0000.0000.0000.0000.0000.00/32', pfx.to_s)

    pfx =  Prefix.new('49.0001.0002.0003/48')
    assert_equal('30490001000200', pfx.to_shex )
    assert_equal('49.0001.0002.0000.0000.0000.0000.0000.0000.0000.00/48', pfx.to_s)

    pfx =  Prefix.new('49.0001.0002.0003/55')
    assert_equal('3749000100020002', pfx.to_shex )
    assert_equal('49.0001.0002.0002.0000.0000.0000.0000.0000.0000.00/55', pfx.to_s)

    pfx =  Prefix.new('49.0001.0002.0003/56')
    assert_equal('3849000100020003', pfx.to_shex )
    assert_equal('49.0001.0002.0003.0000.0000.0000.0000.0000.0000.00/56', pfx.to_s)

    assert ! pfx.ipv4?
    assert ! pfx.ipv6?
    assert   pfx.iso?
    assert_equal(3, pfx.afi)
    assert_equal('NSAP=49.0001.0002.0003.0000.0000.0000.0000.0000.0000.00/56', pfx.to_s_with_afi)
  end
  
  def test_new_ntop_inet
  end
  def test_new_ntop_inet6
  end
  def test_new_ntop_nsap
  end
  def test_new_ntop_inet_extended
  end
  def test_new_ntop_inet6_extended
  end
  def test_new_ntop_nsap_extended
  end
  
end


__END__


def test_inet
  pfx =  Prefix.new_inet('10.0.0.0')
  assert_equal('10.0.0.0/32', pfx.to_s)
  assert_equal('200a000000', pfx.to_shex)
  pfx =  Prefix.new_inet('10.1.1.1/16')
  assert_equal('10.1.0.0/16', pfx.to_s)
  assert_equal('100a01', pfx.to_shex)
  pfx =  Prefix.new_inet('10.255.255.255/17')
  assert_equal('10.255.128.0/17', pfx.to_s)
  assert_equal('110aff80', pfx.to_shex)

end
def test_inet6
  pfx =  Prefix.new_inet6('2011:13:11::0/64')
  assert_equal('2011:13:11::/64', pfx.to_s)
  assert_equal('402011001300110000', pfx.to_shex)
  pfx =  Prefix.new_inet6('2011:13:11::0')
  assert_equal('2011:13:11::/128', pfx.to_s)
  assert_equal('8020110013001100000000000000000000', pfx.to_shex)
end
def test_nsap
  pfx =  Prefix.new_iso('49.0001.0002.0003')
  assert_equal('9849000100020003000000000000000000000000', pfx.to_shex )
  assert_equal('49.0001.0002.0003.0000.0000.0000.0000.0000.0000.00/152', pfx.to_s)
  pfx =  Prefix.new_iso('49.0001.0002.0003/32')
  p pfx
  assert_equal('2049000100', pfx.to_shex )
  assert_equal('49.0001.0000.0000.0000.0000.0000.0000.0000.0000.00/32', pfx.to_s)

  pfx =  Prefix.new_iso('49.0001.0002.0003/48')
  p pfx
  assert_equal('30490001000200', pfx.to_shex )
  assert_equal('49.0001.0002.0000.0000.0000.0000.0000.0000.0000.00/48', pfx.to_s)

  pfx =  Prefix.new_iso('49.0001.0002.0003/55')
  p pfx
  assert_equal('3749000100020002', pfx.to_shex )
  assert_equal('49.0001.0002.0002.0000.0000.0000.0000.0000.0000.00/55', pfx.to_s)

  pfx =  Prefix.new_iso('49.0001.0002.0003/56')
  p pfx
  assert_equal('3849000100020003', pfx.to_shex )
  assert_equal('49.0001.0002.0003.0000.0000.0000.0000.0000.0000.00/56', pfx.to_s)
end

def test_factory_inet
  pfx = Prefix.factory(Prefix.new('10.255.128.0/17').encode)
  assert_equal('10.255.128.0/17', pfx.to_s)
  assert_equal('110aff80', pfx.to_shex)
end
def test_factory_inet6
  pfx = Prefix.factory(Prefix.new('10.255.128.0/17').encode)
  assert_equal('10.255.128.0/17', pfx.to_s)
  assert_equal('110aff80', pfx.to_shex)
end
def test_factory_iso
end

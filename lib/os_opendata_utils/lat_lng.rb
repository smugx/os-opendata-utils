module OsOpendataUtils
  class LatLng
  
    include Utilities

    attr_accessor :lat, :lng
  
    def initialize(lat, lng)
      @lat = lat
      @lng = lng
      osgb36_to_wgs84!
    end
  
    def to_s
      "(%f, %f)" % [@lat, @lng]
    end
  
    def osgb36_to_wgs84!
      airy1830 =  RefEll.new(6377563.396, 6356256.909)
      a        = airy1830.maj
      b        = airy1830.min
      eSquared = airy1830.ecc
      phi = deg_to_rad(@lat)
      lambda = deg_to_rad(@lng)
      v = a / (Math::sqrt(1 - eSquared * sin_squared(phi)));
      h = 0
      x = (v + h) * Math::cos(phi) * Math::cos(lambda)
      y = (v + h) * Math::cos(phi) * Math::sin(lambda)
      z = ((1 - eSquared) * v + h) * Math::sin(phi)

      tx =        446.448;
      ty =       -124.157;
      tz =        542.060;
      s  =         -0.0000204894;
      rx = deg_to_rad( 0.00004172222);
      ry = deg_to_rad( 0.00006861111);
      rz = deg_to_rad( 0.00023391666);

      xB = tx + (x * (1 + s)) + (-rx * y) + (ry * z)
      yB = ty + (rz * x) + (y * (1 + s)) + (-rx * z)
      zB = tz + (-ry * x) + (rx * y) + (z * (1 + s));

      wgs84 = Geo::RefEll.new(6378137.000, 6356752.3141);
      a        = wgs84.maj
      b        = wgs84.min
      eSquared = wgs84.ecc

      lambdaB = rad_to_deg(Math::atan(yB / xB))
      p = Math::sqrt((xB * xB) + (yB * yB))
      phiN = Math::atan(zB / (p * (1 - eSquared)))
      1.upto(10) do
        v = a / (Math::sqrt(1 - eSquared * sin_squared(phiN)))
        phiN1 = Math::atan((zB + (eSquared * v * Math::sin(phiN))) / p)
        phiN = phiN1
      end

      phiB = rad_to_deg(phiN);
      
      @lat = phiB
      @lng = lambdaB
      
      self
    end

  end
end
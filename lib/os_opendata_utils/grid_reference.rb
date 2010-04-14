module OsOpendataUtils
  class GridReference

    require 'os_opendata_utils/utilities'
    include OsOpendataUtils::Utilities

    attr_accessor :easting, :northing

    OSGB_F0  = 0.9996012717
    N0       = -100000.0
    E0       = 400000.0
  
    def initialize(easting, northing)
      @easting = easting
      @northing = northing
    end

    def to_lat_lng
      airy1830 = RefEll.new(6377563.396, 6356256.909)
      phi0     = deg_to_rad(49.0)
      lambda0  = deg_to_rad(-2.0)
      a        = airy1830.maj
      b        = airy1830.min
      eSquared = airy1830.ecc
      phi      = 0.0
      lambda   = 0.0
      n        = (a - b) / (a + b)
      m        = 0.0
      phiPrime = ((@northing - N0) / (a * OSGB_F0)) + phi0
      begin
        m = \
          (b * OSGB_F0) \
            * (((1 + n + ((5.0 / 4.0) * n * n) + ((5.0 / 4.0) * n * n * n)) \
              * (phiPrime - phi0)) \
              - (((3 * n) + (3 * n * n) + ((21.0 / 8.0) * n * n * n)) \
                * Math::sin(phiPrime - phi0) \
                * Math::cos(phiPrime + phi0)) \
              + ((((15.0 / 8.0) * n * n) + ((15.0 / 8.0) * n * n * n)) \
                * Math::sin(2.0 * (phiPrime - phi0)) \
                * Math::cos(2.0 * (phiPrime + phi0))) \
              - (((35.0 / 24.0) * n * n * n) \
                * Math::sin(3.0 * (phiPrime - phi0)) \
                * Math::cos(3.0 * (phiPrime + phi0))))
        phiPrime += (@northing - N0 - m) / (a * OSGB_F0)
      end while ((@northing - N0 - m) >= 0.001)
    
      v = a * OSGB_F0 * ((1.0 - eSquared * sin_squared(phiPrime)) ** -0.5)
      rho = \
        a \
          * OSGB_F0 \
          * (1.0 - eSquared) \
          * ((1.0 - eSquared * sin_squared(phiPrime)) ** -1.5)
      etaSquared = (v / rho) - 1.0
      vii = Math::tan(phiPrime) / (2 * rho * v)
      viii = \
        (Math::tan(phiPrime) / (24.0 * rho * (v ** 3.0))) \
          * (5.0 \
            + (3.0 * tan_squared(phiPrime)) \
            + etaSquared \
            - (9.0 * tan_squared(phiPrime) * etaSquared))
      ix = \
        (Math::tan(phiPrime) / (720.0 * rho * (v ** 5.0))) \
          * (61.0 \
            + (90.0 * tan_squared(phiPrime)) \
            + (45.0 * tan_squared(phiPrime) * tan_squared(phiPrime)))
      x = sec(phiPrime) / v
      xi = \
        (sec(phiPrime) / (6.0 * v * v * v)) \
          * ((v / rho) + (2 * tan_squared(phiPrime)))
      xii = \
        (sec(phiPrime) / (120.0 * (v ** 5.0))) \
          * (5.0 \
            + (28.0 * tan_squared(phiPrime)) \
            + (24.0 * tan_squared(phiPrime) * tan_squared(phiPrime)))
      xiia = \
        (sec(phiPrime) / (5040.0 * (v ** 7.0))) \
          * (61.0 \
            + (662.0 * tan_squared(phiPrime)) \
            + (1320.0 * tan_squared(phiPrime) * tan_squared(phiPrime)) \
            + (720.0 \
              * tan_squared(phiPrime) \
              * tan_squared(phiPrime) \
              * tan_squared(phiPrime)))
      phi = \
        phiPrime \
          - (vii * ((@easting - E0) ** 2.0)) \
          + (viii * ((@easting - E0) ** 4.0)) \
          - (ix * ((@easting - E0) ** 6.0))
      lambda = \
        lambda0 \
          + (x * (@easting - E0)) \
          - (xi * ((@easting - E0) ** 3.0)) \
          + (xii * ((@easting - E0) ** 5.0)) \
          - (xiia * ((@easting - E0) ** 7.0))

      return LatLng.new(rad_to_deg(phi), rad_to_deg(lambda))
    end

  end
end
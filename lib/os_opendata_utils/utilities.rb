module OsOpendataUtils
  module Utilities

    private
  
    def deg_to_rad(deg)
      deg.to_f * (Math::PI / 180.0)
    end

    def rad_to_deg(rad)
      rad.to_f * (180.0/Math::PI)
    end

    def sin_squared(x)
      Math::sin(x) ** 2
    end

    def cos_squared(x)
      Math::cos(x) ** 2
    end

    def tan_squared(x)
      Math::tan(x) ** 2
    end

    def sec(x)
      1.0 / Math::cos(x)
    end
  end

end
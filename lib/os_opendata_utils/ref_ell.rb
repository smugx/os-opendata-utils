module OsOpendataUtils
  class RefEll
  
    attr_accessor :maj, :min, :ecc
  
    def initialize(maj, min)
      @maj = maj
      @min = min
      @ecc = ((@maj * @maj) - (@min * @min)) / (@maj * @maj); 
    end
  end
end
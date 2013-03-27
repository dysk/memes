# coding: UTF-8

module RandomData
  class Password
    def initialize(len=8)
      @value = ::SecureRandom.base64(len).tr('+/=','xyz')
    end

    def to_s
      return "#{@value}"
    end
  end

  class Id
    def initialize(length=9)
      @value = Array.new(length){ ::SecureRandom.random_number(10) }.join
    end

    def to_s
      return "#{@value}"
    end
  end
end

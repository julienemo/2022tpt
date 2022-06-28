require 'pry'

class Helper
  class << self
    def constantize(class_name)
      Kernel.const_get(class_name.capitalize)
    end
  end
end

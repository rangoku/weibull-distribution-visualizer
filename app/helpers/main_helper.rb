module MainHelper
  class Weibull
    attr_accessor :shape, :scale # k and lambda

    def initialize(k, lamb)
      self.shape = k.to_r
      self.scale = lamb.to_r
    end

    def density_function(value)
      return if shape <= 0 || scale <= 0
      return 0 if value < 0

      left = shape / scale
      center = (value / scale) ** (shape - 1)
      right = Math.exp(-((value/scale) ** shape))

      left * center * right
    end

    def random_inverse
      ((-1 / scale) * Math.log(1 - rand)) ** (1 / shape)
    end

    def random_neumann
      w = 0
      n = 1000

      n.times do |i|
        wi = density_function i / n
        if wi > w
          w = wi
        end
      end

      while true
        g1 = rand
        g2 = rand
        x = g1
        y = w * g2
        if density_function(x) > y
          return x
        end
      end
    end

    def random_metropolis
      x0 = 0.5
      del = 0.2
      n = 1000

      f = lambda {
        x = x0 + (-1 + 2 * rand) * del
        a = x > 0 && x < 1 ? density_function(x) / density_function(x0) : 0
        if a >= 1 || rand < a
          x0 = x
        end

        return x0
      }

      n.times do
        f.call
      end

      f.call
    end
  end
end

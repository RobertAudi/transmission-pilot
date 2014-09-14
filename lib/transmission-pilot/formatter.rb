module TransmissionPilot
  class Formatter
    def self.size(size)
      return "Zero" unless size.filesize?

      conv  = %w( B KB MB GB TB PB EB )
      scale = 1024

      index = 1
      if size < 2 * (scale ** index)
        return "#{size.floor} #{conv[index - 1]}"
      end

      size = size.to_f

      5.times do |i|
        if size < 2 * (scale ** (i + 2))
          return "#{(size / (scale ** (i + 1))).floor} #{conv[i + 1]}"
        end
      end

      "#{(size / (scale ** 6)).floor} #{conv[6]}"
    end
  end
end

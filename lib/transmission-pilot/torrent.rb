require_relative "formatter"

module TransmissionPilot
  class Torrent
    KEYS = {
      name:          "name",
      started_on:    "startDate",
      finished_on:   "doneDate",
      finished:      "isFinished",
      eta:           "eta",
      progress:      "percentDone",
      priorities:    "priorities",
      download_rate: "rateDownload",
      upload_rate:   "rateUpload",
      total_size:    "totalSize"
    }

    attr_reader :name, :started_on, :finished_on, :eta, :priorities,
      :progress, :download_rate, :upload_rate

    def initialize(raw = nil)
      if raw.is_a?(Hash)
        @raw = raw

        serialize!
      end
    end

    def serialize!
      return unless @raw.is_a?(Hash)

      @name = @raw.fetch(KEYS[:name], "")
      @progress = @raw.fetch(KEYS[:progress], 0)
      @priorities = @raw.fetch(KEYS[:priorities], Array.new)
      @download_rate = @raw.fetch(KEYS[:download_rate], 0)
      @upload_rate = @raw.fetch(KEYS[:upload_rate], 0)
      @finished = @raw.fetch(KEYS[:finished], false)

      start_date = @raw.fetch(KEYS[:started_on], nil)
      if start_date
        @started_on = Date.strptime(start_date.to_s, "%s")
      end

      done_date = @raw.fetch(KEYS[:finished_on], nil)
      if finished? && done_date
        @finished_on = Date.strptime(done_date.to_s, "%s")
      else
        @finished_on = Date::Infinity.new
      end

      eta = @raw.fetch(KEYS[:eta], nil)
      if finished? && eta
        @eta = Date.strptime(eta.to_s, "%s")
      else
        @eta = Date::Infinity.new
      end

      @raw_total_size = @raw.fetch(KEYS[:total_size], 0)
      @total_size = TransmissionPilot::Formatter.size(@raw_total_size)

      @raw = nil
    end

    def total_size(raw = false)
      return raw ? @raw_total_size : @total_size
    end

    def finished?
      !!@finished
    end
  end
end

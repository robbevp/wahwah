# frozen_string_literal: true

module WahWah
  class Mp3Tag
    TAG_ATTRIBUTES = %i(
      title
      artist
      album
      albumartist
      composer
      comments
      track
      track_total
      file_size
      genre
      year
      disc
      disc_total
      images
    )

    def self.add_tag_attributes(attributes)
      attributes.each do |attr|
        define_method(attr) { @id3_tag&.send(attr) }
      end
    end

    add_tag_attributes TAG_ATTRIBUTES

    def initialize(file_path)
      @file_io = File.open(file_path)

      parse_id3_version
      parse_tag(file_path)
      parse_duration
    end

    def id3v1?
      @id3_version == 1
    end

    def id3v2?
      @id3_version == 2
    end

    def invalid_id3?
      @id3_version == 0
    end

    def id3_version
      if id3v1?
        'v1'
      elsif id3v2?
        "v#{@id3_version}.#{@id3_tag.major_version}"
      end
    end

    def mpeg_version
      @mpeg_frame_header.version
    end

    def mpeg_layer
      @mpeg_frame_header.layer
    end

    def mpeg_kind
      @mpeg_frame_header.kind
    end

    def mpeg_frame_bitrate
      @mpeg_frame_header.frame_bitrate
    end

    def channel_mode
      @mpeg_frame_header.channel_mode
    end

    def sample_rates
      @mpeg_frame_header.sample_rates
    end

    def xing_header
      @xing_header ||= parse_xing_hader
    end

    def vbri_header
    end

    private
      def parse_id3_version
        # Invalid id3 version
        @id3_version = 0

        @file_io.seek(-ID3::V1::TAG_SIZE, IO::SEEK_END)
        @id3_version = 1 if @file_io.read(3) == ID3::V1::TAG_ID

        @file_io.rewind
        @id3_version = 2 if @file_io.read(3) == ID3::V2::TAG_ID
      end

      def parse_tag(file_path)
        @id3_tag = if id3v2?
          ID3::V2.new(file_path)
        elsif id3v1?
          ID3::V1.new(file_path)
        end
      end

      def parse_duration
        # Because id3v2 tag on the file header so skip id3v2 tag
        @mpeg_frame_header = Mp3::MpegFrameHeader.new(@file_io, id3v2? ? @id3_tag.size : 0)
      end

      def parse_xing_hader
      end
  end
end

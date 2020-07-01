# frozen_string_literal: true

module WahWah
  module Asf
    # The base unit of organization for ASF files is called the ASF object.
    # It consists of a 128-bit GUID for the object, a 64-bit integer object size, and the variable-length object data.
    # The value of the object size field is the sum of 24 bytes plus the size of the object data in bytes.
    # The following diagram illustrates the ASF object structure:
    #
    # 16 bytes: Object GUID
    # 8 bytes: Object size
    # variable-sized: Object data
    class Object
      HEADER_SIZE = 24
      HEADER_FORMAT = 'a16Q<'

      attr_reader :size, :guid

      def initialize(file_io)
        guid_bytes, @size = file_io.read(HEADER_SIZE)&.unpack(HEADER_FORMAT)
        return unless valid?

        @size = @size - HEADER_SIZE
        @guid = Helper.byte_string_to_guid(guid_bytes)
        @file_io = file_io
        @position = file_io.pos
      end

      def valid?
        !@size.nil? && @size >= HEADER_SIZE
      end

      def data
        @file_io.seek(@position)
        @file_io.read(size)
      end
    end
  end
end

# src/theme/config/plist.cr
require "xml"
require "base64"

module Theme::Config
  alias PlistValue = Hash(String, PlistValue) | Array(PlistValue) | String | Float64 | Int64 | Bool | Bytes

  # Reads Apple property lists, both the XML and the binary ("bplist00")
  # flavor. Only the types found in terminal theme files are supported:
  # dict, array, string, real, integer, data, true, false.
  module Plist
    extend self

    def parse(text : String) : PlistValue
      stripped = text.lstrip("\uFEFF \t\r\n")
      stripped.starts_with?("bplist00") ? Bplist.parse(stripped.to_slice) : parse_xml(text)
    end

    def parse(bytes : Bytes) : PlistValue
      if bytes.size >= 8 && String.new(bytes[0, 8]) == "bplist00"
        Bplist.parse(bytes)
      else
        parse(scrub_utf8(bytes))
      end
    end

    # Decodes bytes as UTF-8, skipping invalid sequences.
    #
    # Not `String.new(bytes, "UTF-8", invalid: :skip)`: that drops one byte
    # per 1024-byte transcoding buffer boundary.
    def self.scrub_utf8(bytes : Bytes) : String
      String.build(bytes.size) do |io|
        i = 0
        while i < bytes.size
          b = bytes[i]
          if b < 0x80
            io.write_byte b
            i += 1
          else
            len = b >= 0xF0 ? 4 : b >= 0xE0 ? 3 : b >= 0xC0 ? 2 : 0
            if len > 0 && i + len <= bytes.size && (1...len).all? { |j| (bytes[i + j] & 0xC0) == 0x80 }
              io.write bytes[i, len]
              i += len
            else
              i += 1 # skip invalid byte
            end
          end
        end
      end
    end

    private def parse_xml(xml_text : String) : PlistValue
      doc   = XML.parse(xml_text)
      plist = doc.root.not_nil!
      parse_element(plist.children.find(&.element?).not_nil!)
    end

    private def parse_element(node : XML::Node) : PlistValue
      case node.name
      when "dict"
        result = Hash(String, PlistValue).new
        key : String? = nil
        node.children.each do |child|
          next unless child.element?
          if child.name == "key"
            key = child.content
          else
            result[key.not_nil!] = parse_element(child)
            key = nil
          end
        end
        result
      when "array"
        node.children.select(&.element?).map { |c| parse_element(c) }
      when "string"  then node.content
      when "real"    then node.content.to_f64
      when "integer" then node.content.to_i64
      when "data"    then Base64.decode(node.content.gsub(/\s/, ""))
      when "true"    then true
      when "false"   then false
      else                raise ParseError.new("unsupported plist element: <#{node.name}>")
      end
    end
  end

  # Reader for binary property lists. See `Plist`.
  module Bplist
    extend self

    def parse(bytes : Bytes) : PlistValue
      trailer     = bytes[-32..]
      offset_size = trailer[6].to_i
      ref_size    = trailer[7].to_i
      num_objects = read_uint(trailer, 8, 8)
      top_object  = read_uint(trailer, 16, 8)
      offset_base = read_uint(trailer, 24, 8)

      offsets = (0...num_objects).map do |i|
        read_uint(bytes, offset_base + i * offset_size, offset_size)
      end

      read_object(bytes, offsets, ref_size, offsets[top_object])
    end

    private def read_object(bytes : Bytes, offsets : Array(Int64), ref_size : Int, pos : Int64) : PlistValue
      marker = bytes[pos]
      type   = marker >> 4
      info   = (marker & 0x0F).to_i

      count_of = ->(p : Int64) do
        if info == 0x0F
          int_marker = bytes[p + 1]
          {p + 2 + int_size(int_marker), read_object(bytes, offsets, ref_size, p + 1).as(Int64).to_i}
        else
          {p + 1, info}
        end
      end

      case type
      when 0x0
        case info
        when 0x08 then false
        when 0x09 then true
        else           raise ParseError.new("unsupported simple plist object #{info}")
        end
      when 0x1
        read_uint(bytes, pos + 1, 1 << info)
      when 0x2
        size = 1 << info
        io   = IO::Memory.new(Bytes.new(bytes.to_unsafe + pos + 1, size, read_only: true))
        size == 4 ? io.read_bytes(Float32, IO::ByteFormat::BigEndian).to_f64 : io.read_bytes(Float64, IO::ByteFormat::BigEndian)
      when 0x4
        start, count = count_of.call(pos)
        bytes[start, count].dup
      when 0x5
        start, count = count_of.call(pos)
        String.new(bytes[start, count])
      when 0x6
        start, count = count_of.call(pos)
        String.build do |io|
          count.times do |i|
            cp = (bytes[start + i * 2].to_i << 8) | bytes[start + i * 2 + 1]
            io << cp.chr
          end
        end
      when 0x8
        read_uint(bytes, pos + 1, info + 1)
      when 0xA
        start, count = count_of.call(pos)
        (0...count).map do |i|
          ref = read_uint(bytes, start + i * ref_size, ref_size)
          read_object(bytes, offsets, ref_size, offsets[ref])
        end
      when 0xD
        start, count = count_of.call(pos)
        result = Hash(String, PlistValue).new
        (0...count).each do |i|
          key_ref = read_uint(bytes, start + i * ref_size, ref_size)
          val_ref = read_uint(bytes, start + (count + i) * ref_size, ref_size)
          key     = read_object(bytes, offsets, ref_size, offsets[key_ref]).as(String)
          result[key] = read_object(bytes, offsets, ref_size, offsets[val_ref])
        end
        result
      else
        raise ParseError.new("unsupported binary plist object type 0x#{type.to_s(16)}")
      end
    end

    private def int_size(marker : UInt8) : Int
      1 << (marker & 0x0F)
    end

    private def read_uint(bytes : Bytes, pos : Int | Int64, size : Int) : Int64
      value = 0_i64
      size.times { |i| value = (value << 8) | bytes[pos + i] }
      value
    end
  end
end

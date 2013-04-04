
module AisTools
  class Loader
    BAR_CHARACTERS = [ "|", "/", "-", "\\" ]

    def initialize(ais, port)
      @baridx = 0
      @ais = ais
      @port = port
      @buffer = ""
    end

    def run!
      while true do
        begin
          start_word_sync
          ping_opcode_sync

          load_ais

        rescue => e
          puts "Load error: #{e}"
        end
      end
    end

    private

    def opcode(words)
      if !words.kind_of? Array
        words = [ words ]
      end

      first = words[0]

      tries = 8
      while true
        write_port [ first ].pack("V")

        response = read_port(4, 0.1)
        if response.nil?
          tries -= 1
          if tries == 0
            raise "opcode timeout"
          end
        else
          break
        end
      end

      response, = response.unpack("V")

      if (first & 0xFF000000) == 0x58000000
        valid_response = (first & 0x00FFFFFF) | 0x52000000
      else
        valid_response = first
      end
      raise "opcode mismatch: #{response.to_s 16}, #{valid_response.to_s 16} response" if response != valid_response
    
      if words.length > 1
        write_port words[1..-1].pack("V*")
      end
    end

    def start_word_sync
      bar_prompt "Start-Word Synchronization"

      begin
        synchronized = false

        until synchronized
          bar_tick

          write_port "\x58"
          until synchronized
            byte = read_port(1)
            break if byte.nil?

            synchronized = true if byte == "\x52"
          end
        end
      ensure
        bar_done
      end
    end

    def ping_opcode_sync
      bar_prompt "Ping Op-Code Synchronization"

      n = 2

      begin
        bar_tick

        opcode 0x5853590B

        bar_tick

        opcode n

        1.upto(n) do |num|
          bar_tick
          opcode num
        end
      ensure
        bar_done
      end
    end

    def load_ais
      bar_prompt "Loading AIS"
      begin
        @ais.instructions.each_with_index do |insn, idx|
          bar_tick

          words = [ insn.opcode ]
          insn.write do |data, pack = true|
            if pack
              if data.kind_of? Array
                words.concat data
              else
                words << data
              end
            else
              words.concat data.unpack("V*")
            end
          end

          opcode words

          sleep 0.1 * words.length / 300.0
        end
      ensure
        bar_done
      end
    end

    def bar_prompt(string)
      print "#{string}  "
    end

    def bar_tick
      char = BAR_CHARACTERS[@baridx]
      @baridx += 1
      @baridx = 0 if @baridx == BAR_CHARACTERS.length
      print "\x08#{char}"
    end

    def bar_done
      puts "\x08 \x08\x08."
    end

    def write_port(data)
      @port.write data
    end

    def read_port(bytes, timeout = 0.25)
      while @buffer.length < bytes
        begin
          return nil if IO.select([ @port ], [], [], timeout).nil?
          chunk = @port.sysread(65536)
          @buffer << chunk
        rescue Errno::EWOULDBLOCK, Errno::EINTR
        end
      end

      @buffer.slice! 0, bytes
    end
  end
end

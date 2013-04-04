module AisTools::CPU::Am17xx
  def configure_pll(opts)
    word1 = ((opts[:pllm] - 1) << 24) |
            ((opts[:postdiv] - 1) << 16) |
            ((opts[:plldiv3] - 1) << 8) |
            (opts[:plldiv5] - 1)

    word2 = (opts[:clkmode] << 24) |
            ((opts[:plldiv7] - 1) << 16) |
            (opts[:locktime] - 1)

    case target
    when 'uart'
      clock = (opts[:uart_osm] << 16) |
              opts[:uart_div]

    else
      clock = 0
    end

    execute_function(5, word1, word2, clock)
  end

  def configure_emifb_sdram(opts)
    execute_function(2, opts[:sdcr], opts[:sdtimr], opts[:sdsretr], opts[:sdrcr])
  end

  def configure_emifa_sdram(opts)
    execute_function(3, opts[:sdcr], opts[:sdtimr], opts[:sdsretr], opts[:sdrcr])
  end

  def configure_psc(opts)
    word = (opts[:controller] << 24) |
           (opts[:module] << 16) |
           (opts[:domain] << 8) |
           opts[:state]

    execute_function(6, word)
  end

  def configure_pinmux(opts)
    execute_function(7, opts[:regnum], opts[:mask], opts[:value])
  end

  def write_byte(address, value, sleep = 0)
    boot_table(0, 0..0, address, value, sleep)
  end

  def write_half(address, value, sleep = 0)
    boot_table(1, 0..0, address, value, sleep)
  end

  def write_word(address, value, sleep = 0)
    boot_table(2, 0..0, address, value, sleep)
  end

  def write_bitfield(address, field, value, sleep = 0)
    boot_table(3, field, address, value, sleep)
  end
end

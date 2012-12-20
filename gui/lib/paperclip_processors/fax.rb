module Paperclip
  class Faxtif < Processor

    attr_accessor :whiny

    def initialize(file, options = {}, attachment = nil)
      super
      @file = file
      # @instance = options[:instance]
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
    end

    def make
      dst = Tempfile.new([ @basename, 'tif' ].compact.join("."))
      dst.binmode

      cmd = "-compress Fax +antialias -support 0 -filter point -resize 1728 -density 204x98 -monochrome -define quantum:polarity=min-is-white pdf:'#{File.expand_path(file.path)}' "
      cmd << "tif:'#{File.expand_path(dst.path)}'"

      begin
        success = Paperclip.run("convert #{cmd}")
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error processing the thumbnail for #{@basename}" if whiny
      end
      dst
    end
  end

  class Faxpdf < Processor

    attr_accessor :whiny

    def initialize(file, options = {}, attachment = nil)
      super
      @file = file
      # @instance = options[:instance]
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
    end

    def make
      dst = Tempfile.new([ @basename, 'pdf' ].compact.join("."))
      dst.binmode
      # dst2 = Tempfile.new([ @basename, 'pdf' ].compact.join("."))
      # dst2.binmode

      cmd = "-compress Fax +antialias -support 0 -filter point -resize 1728 -density 204x98 -monochrome -define quantum:polarity=min-is-white pdf:'#{File.expand_path(file.path)}' "
      cmd << "pdf:'#{File.expand_path(dst.path)}'"

      # cmd2 = "tif:'#{File.expand_path(dst.path)}' pdf:'#{File.expand_path(dst2.path)}' "

      begin
        # first we make a TIF from the PDF in fax capable format
        success = Paperclip.run("convert #{cmd}")
        # now we do something really stupid, we convert everything back to PDF 
        # we need this to be able to send confirmations via email, and TIF images could have some problems
        # and we want't to send a confirmation containing the PDF how it would look as a fax
        # so just to be on the safe side, back to PDF it is ... 
        #success = Paperclip.run("convert #{cmd2}")
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error processing the thumbnail for #{@basename}" if whiny
      end
      dst
    end
  end

end
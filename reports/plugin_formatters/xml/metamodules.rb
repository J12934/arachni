=begin
                  Arachni
  Copyright (c) 2010-2011 Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

module Arachni

require Arachni::Options.instance.dir['reports'] + '/xml/buffer.rb'

module Reports

class XML
    module PluginFormatters

        #
        # XML formatter for the results of the MetaModules plugin
        #
        # @author: Tasos "Zapotek" Laskos
        #                                      <tasos.laskos@gmail.com>
        #                                      <zapotek@segfault.gr>
        # @version: 0.1
        #
        class MetaModules

            include Arachni::Reports::Buffer

            def initialize( plugin_data )
                @results     = plugin_data[:results]
                @description = plugin_data[:description]
            end

            def run
                start_tag( 'metamodules' )
                simple_tag( 'description', @description )
                start_tag( 'results' )

                format_meta_results( @results ).values.each { |xml| append( xml ) }

                end_tag( 'results' )
                end_tag( 'metamodules' )
            end

            #
            # Runs plugin formatters for the running report and returns a hash
            # with the prepared/formatted results.
            #
            # @param    [AuditStore#plugins]      plugins   plugin data/results
            #
            def format_meta_results( plugins )

                ancestor = self.class.ancestors[0]

                # add the PluginFormatters module to the report
                eval( "module  MetaFormatters end" )

                # prepare the directory of the formatters for the running report
                lib = File.dirname( __FILE__ ) + '/metaformatters/'

                # initialize a new component manager to handle the plugin formatters
                formatters = ::Arachni::Report::FormatterManager.new( lib, ancestor.const_get( 'MetaFormatters' ) )

                # load all the formatters
                formatters.load( ['*'] )

                # run the formatters and gather the formatted data they return
                formatted = {}
                formatters.each_pair {
                    |name, formatter|
                    plugin_results = plugins[name]
                    next if !plugin_results || plugin_results[:results].empty?

                    formatted[name] = formatter.new( plugin_results.deep_clone ).run
                }

                return formatted
            end


        end

    end
end

end
end

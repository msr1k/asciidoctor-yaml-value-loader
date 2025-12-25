require 'asciidoctor'
# require 'asciidoctor-yaml-value-loader'
require_relative '../lib/asciidoctor-yaml-value-loader'

Asciidoctor.convert_file 'b/b.adoc', safe: :safe


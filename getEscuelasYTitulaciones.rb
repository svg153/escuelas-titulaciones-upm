#!/usr/bin/env ruby
#!/usr/bin/ruby
#!/usr/local/bin/ruby

require 'rubygems'
require 'optparse'
require 'yaml'
require 'json'
require 'nokogiri'
require 'mechanize'
require 'httparty'
  # https://www.distilled.net/resources/web-scraping-with-ruby-and-nokogiri-for-beginners/
  # https://github.com/jnunemaker/httparty


$loud = true

AUTHORS = ["@svg153"]

URI_escuelas = 'https://www.upm.es/wapi_upm/academico/comun/index.upm/v2/centro.json'

def getAuthors
  str = "Authors: "
  AUTHORS.each_with_index do |author, index|
    str += author
    (index == AUTHORS.size - 1) ? str += "." : str += ", "
  end
  return str
end


public

def strip_empties(json)
  json.each_with_object([]) do |record, results|
    record.each do |key, value|
      if value.is_a? Array
        results << { key => strip_empties(value) }
      else
        results << { key => value } unless value == ""
      end
    end
  end
end




$file = 'upm.json'
$escuelas_json = {}
$titulaciones_json = {}
$out_str_json = {}


# begin the session
print "abriendo sesion... " if $loud
escuelas_api_resp = HTTParty.get(URI_escuelas);
#puts $escuelas_api_resp
body_escuelas_api_resp_json = escuelas_api_resp.body
#print $body_escuelas_api_resp_json
escuelas_json = JSON.parse(body_escuelas_api_resp_json)
puts $escuelas_json
puts "OK" if $loud && $escuelas_json

abort "no se ha podido conectar con la API." unless $escuelas_json

puts "congiendo las titulaciones de cada escuela... " if $loud
escuelas_json.each do |objId, objGET|

  codigo_escuela = $escuelas_json['codigo']
  nombre_escuela = $escuelas_json['nombre']
  print "\t [#{codigo_escuela}] #{nombre_escuela}" if $loud

  # https://www.upm.es/wapi_upm/academico/comun/index.upm/v2/centro.json/4/planes/PSC
  uri_titulaciones_escuela = "#{URI_escuelas}" + "/#{codigo_escuela}" + "/planes/PSC"

  titulaciones_api_resp = $agent.get(uri_titulaciones_escuela)
  body_titulaciones_api_resp= titulaciones_api_resp.body
  $titulaciones_json = JSON.parse(body_titulaciones_api_resp)

  puts "OK" if $loud && titulaciones_json
  abort "No se ha podido coger las titulaciones." unless titulaciones_json

end



out_file = File.new("out.txt", "w")
#...
out_file.puts("write your stuff here")
#...
out_file.close

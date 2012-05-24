require 'xml'
require 'json'
require 'net/http'

HOST = 'www.melbourneguidedawg.com'
PORT = 80
TOILET_CATEGORY = '1'
NAMESPACE_PREFIX = 't'

def element_for_xpath(doc, xpath)
  doc.find( NAMESPACE_PREFIX + ':' + xpath ).first.content
end

if __FILE__ == $PROGRAM_NAME
  parser = XML::Parser.file('ToiletmapExport.xml')
  doc = parser.parse

  doc.root.namespaces.default_prefix = NAMESPACE_PREFIX

  doc.find('//toilet:ToiletDetails', 'toilet:http://toiletmap.gov.au/').each do |s|
    if s.find('t:Town').first.content == 'Melbourne'
      
      name = element_for_xpath s, 'Name'
      address1 = element_for_xpath s, 'Address1'
      town = 'Melbourne'
      state = element_for_xpath s, 'State'
      postcode = element_for_xpath s, 'Postcode'
      
      is_open = s.find('t:OpeningHours').first.find('t:IsOpen').first.content
      
      male = s.find('t:GeneralDetails').first.find('t:Male').first.content == 'true' ? 'Male' : nil
      female = s.find('t:GeneralDetails').first.find('t:Female').first.content == 'true' ? 'Female' : nil
      payment_required = s.find('t:GeneralDetails').first.find('t:PaymentRequired').first.content == 'true' ? 'Payment Required' : nil
      key_required = s.find('t:GeneralDetails').first.find('t:KeyRequired').first.content == 'true' ? 'Key Required' : nil
      
      male_accessible = s.find('t:AccessibilityDetails').first.find('t:AccessibleMale').first.content == 'true' ? 'Male' : nil
      female_accessible = s.find('t:AccessibilityDetails').first.find('t:AccessibleFemale').first.content == 'true' ? 'Female' : nil
      unisex_accessible = s.find('t:AccessibilityDetails').first.find('t:AccessibleUnisex').first.content == 'true' ? 'Unisex' : nil
      
      baby_change = s.find('t:Features').first.find('t:BabyChange').first.content == 'true' ? 'Baby changing facilities available' : nil
      showers = s.find('t:Features').first.find('t:Showers').first.content == 'true' ? 'Shower facilities available' : nil
      drinking_water = s.find('t:Features').first.find('t:DrinkingWater').first.content == 'true' ? 'Drinking water facilities available' : nil
      sharps_disposal = s.find('t:Features').first.find('t:SharpsDisposal').first.content == 'true' ? 'Sharps disposal facilities available' : nil
      sanitary_disposal = s.find('t:Features').first.find('t:SanitaryDisposal').first.content == 'true' ? 'Sanitary disposal facilities available' : nil
      
      lat = s.attributes['Latitude']
      lng = s.attributes['Longitude']
      
      #build up address
      address = [address1, town, state, postcode].find_all{ |i| i != '' }.join(', ')
      
      #build up general details
      male_female = [male, female].find_all { |i| i != nil }.join('/')
      male_female = male_female != '' ? male_female : nil       
      opening_hours = is_open == 'AllHours' ? "Opening Hours: 24h" : 'Opening Hours: Limited'
      details_text = [male_female, opening_hours, payment_required, key_required].find_all{ |i| i != nil }.join("\n- ")
      general_details = details_text != '' ? "General Details:\n- #{details_text}" : nil
      
      #build up accessbility
      accessiblity = [male_accessible, female_accessible, unisex_accessible].find_all { |i| i != nil }.join("\n- ")
      accessiblity_details = accessiblity != '' ? "Accessibility Details:\n- #{accessiblity}" : nil
      
      #build up features
      features = [baby_change, showers, drinking_water, sharps_disposal, sanitary_disposal].find_all { |i| i != nil }.join("\n- ")
      features_details = features != '' ? "Features:\n- #{features}" : nil
      
      #build up whole description
      description = [general_details, accessiblity_details, features_details].find_all { |i| i != nil }.join("\n\n")
      
      puts "--------"
      puts description
      puts ''
      
      json = { 
         :name => name,
         :lat => lat.to_f, 
         :lng => lng.to_f,
         :address => address,
         :text => description,
         :category_id => TOILET_CATEGORY
       }.to_json
       
       req = Net::HTTP::Post.new('/places.json', initheader = {'Content-Type' => 'application/json', 'Accepts' => 'application/json'})
       req.basic_auth 'guide_dawg', 'fd423kj322lnn3ld'
       req.body = json
       response = Net::HTTP.new(HOST, PORT).start {|http| http.request(req) }
       puts "Response #{response.code} #{response.message}:#{response.body}"
       
    end
  end  
end
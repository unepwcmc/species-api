class Api::V1::CitesLegislationController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
    name 'CITES Legislation'
  end

  api :GET, '/:taxon_concept_id/cites_legislation', 'Lists current CITES appendix listings and reservations, CITES quotas, and CITES suspensions for a given taxon concept'

  description <<-EOS
==== cites_listings
[id] these records may cascade from higher taxonomic level, so this value is inherited and the same record may be returned in different contexts.
[taxon_concept_id] always present
[is_current] boolean flag indicating whether listing chane is current
[appendix] CITES appendix, one of <tt>I</tt>, <tt>II</tt> or <tt>III</tt> [max 255 characters]
[change_type] type of listing change, one of:
<tt>+</tt>: inclusion in appendix,

<tt>-</tt>: removal from appendix,

<tt>R+</tt>: reservation entered,

<tt>R-</tt>: reservation withdrawn

[effective_at] date when listing change came into effect, YYYY-MM-DD
[party] where applicable, CITES party involved in the listing change. See description of <tt>geo_entity</tt> object below.
[annotation] text of annotation (translated based on locale)
[hash_annotation] where applicable, <tt>#</tt> annotation (plants). See description of <tt>annotation</tt> object below.

==== cites_quotas
[id] these records may cascade from higher taxonomic level, so this value is inherited and the same record may be returned in different contexts.
[taxon_concept_id] always present
[quota] numeric value
[publication_date] date when quota was published, YYYY-MM-DD
[notes] comments [unlimited length]
[url] URL of original document [unlimited length]
[is_current] boolean flag indicating whether quota is current
[unit] quota unit, see description of <tt>trade_code</tt> below
[geo_entity] geographic location to which the quota applies. See description of <tt>geo_entity</tt> object below.

==== cites_suspensions
[id] these records may cascade from higher taxonomic level, so this value is inherited and the same record may be returned in different contexts.
[taxon_concept_id] empty when suspension applies to all taxa in given location
[notes] comments [unlimited length]
[start_date] date when suspension came into effect, YYYY-MM-DD
[is_current] boolean flag indicating whether suspension is current
[geo_entity] geographic location to which the suspension applies. See description of <tt>geo_entity</tt> object below.
[applies_to_import] boolean flag which indcates whether suspension applies to import into the specified geographic location (applies to export by default).
[start_notification] Suspension Notification document. See description of <tt>event</tt> object below.

==== geo_entity
[iso_code2] ISO 3166-1 alpha-2 [max 255 characters]
[name] name of country / territory (translated based on locale) [max 255 characters]
[type] one of <tt>COUNTRY</tt> or <tt>TERRITORY</tt> [max 255 characters]

==== trade_code
[code] CITES trade code [max 255 characters]
[name] name (translated based on locale) [max 255 characters]

==== event
[name] name of event [max 255 characters]
[date] date of event
[url] URL of document [unlimited length]

==== annotation
[symbol] symbol of annotation [max 255 characters]
[note] text of annotation (translated based on locale) [unlimited length]


  EOS

  param :taxon_concept_id, String, :desc => "Taxon Concept ID", :required => true
  param :scope, String, desc: 'Time scope of legislation. Select all, current or historic. Defaults to current.', required: false
  param :language, String, desc: 'Select language for the text of legislation notes. Select en, fr, or es. Defaults to en.', required: false
  example <<-EOS
  {
    "cites_listings":[
      {
        "taxon_concept_id":4521,
        "is_current":true,
        "appendix":"II",
        "change_type":"+",
        "effective_at":"2007-09-13",
        "annotation":"The populations of Botswana, Namibia, South Africa and Zimbabwe are listed in Appendix II for the exclusive purpose of allowing: [...]"
      },
      {
        "taxon_concept_id":4521,
        "is_current":true,
        "appendix":"I",
        "change_type":"+",
        "effective_at":"2007-09-13",
        "annotation":"Included in Appendix I, except the populations of Botswana, Namibia, South Africa and Zimbabwe, which are included in Appendix II."
      },
      {
        "taxon_concept_id":4521,
        "is_current":true,
        "appendix":"I",
        "change_type":"R+",
        "effective_at":"1990-01-18",
        "annotation":null,
        "party":{
          "iso_code2":"MW",
          "name":"Malawi",
          "type":null
        }
      }
    ],
    "cites_quotas":[
      {
        "taxon_concept_id":4521,
        "quota":180.0,
        "publication_date":"2014-03-14",
        "notes":"tusks as trophies from 90 animals",
        "url":null,
        "public_display":true,
        "is_current":true,
        "unit":null,
        "geo_entity":{
          "iso_code2":"NA",
          "name":"Namibia",
          "type":"COUNTRY"
        }
      },
      {
        "taxon_concept_id":4521,
        "quota":160.0,
        "publication_date":"2014-03-14",
        "notes":"tusks as trophies from 80 animals",
        "url":null,
        "public_display":true,
        "is_current":true,
        "unit":null,
        "geo_entity":{
          "iso_code2":"CM",
          "name":"Cameroon",
          "type":"COUNTRY"
        }
      }
    ],
    "cites_suspensions":[
      {
        "taxon_concept_id":null,
        "notes":"All commercial trade in specimens of CITES-listed species.",
        "start_date":"2004-07-30",
        "is_current":true,
        "applies_to_import":false,
        "geo_entity":{
          "iso_code2":"SO",
          "name":"Somalia",
          "type":"COUNTRY"
        },
        "start_notification":{
          "name":"CITES Notif. No. 2004/055",
          "date":"2004-07-30",
          "url":"http://www.cites.org/eng/notif/2004/055.pdf"
        }
      },
      {
        "taxon_concept_id":4521,
        "notes":"The United States has suspended imports of sport-hunted trophies of African elephant taken in Zimbabwe on or after 4 April 2014.",
        "start_date":"2014-08-11",
        "is_current":true,
        "applies_to_import":false,
        "geo_entity":{
          "iso_code2":"ZW",
          "name":"Zimbabwe",
          "type":"COUNTRY"
        },
        "start_notification":{
          "name":"CITES Notif. No. 2014/037",
          "date":"2014-08-11",
          "url":"http://cites.org/sites/default/files/notif/E-Notif-2014-037.pdf"
        }
      }
    ]
  }
  EOS

  example <<-EOS
  <?xml version="1.0" encoding="UTF-8"?>
  <cites-legislation>
    <cites-listings type="array">
      <cites-listing>
        <taxon-concept-id type="integer">4521</taxon-concept-id>
        <is-current type="boolean">true</is-current>
        <appendix>II</appendix>
        <change-type>+</change-type>
        <effective-at type="date">2007-09-13</effective-at>
        <annotation>The populations of Botswana, Namibia, South Africa and Zimbabwe are listed in Appendix II for the exclusive purpose of allowing: [...]</annotation>
      </cites-listing>
      <cites-listing>
        <taxon-concept-id type="integer">4521</taxon-concept-id>
        <is-current type="boolean">true</is-current>
        <appendix>I</appendix>
        <change-type>+</change-type>
        <effective-at type="date">2007-09-13</effective-at>
        <annotation>Included in Appendix I, except the populations of Botswana, Namibia, South Africa and Zimbabwe, which are included in Appendix II.</annotation>
      </cites-listing>
      <cites-listing>
        <taxon-concept-id type="integer">4521</taxon-concept-id>
        <is-current type="boolean">true</is-current>
        <appendix>I</appendix>
        <change-type>R+</change-type>
        <effective-at type="date">1990-01-18</effective-at>
        <annotation nil="true"/>
        <party>
          <iso-code2>MW</iso-code2>
          <name>Malawi</name>
          <type nil="true"/>
        </party>
      </cites-listing>
    </cites-listings>
    <cites-quotas type="array">
      <cites-quota>
        <taxon-concept-id type="integer">4521</taxon-concept-id>
        <quota type="float">180.0</quota>
        <publication-date type="date">2014-03-14</publication-date>
        <notes>tusks as trophies from 90 animals</notes>
        <url nil="true"/>
        <public-display type="boolean">true</public-display>
        <is-current type="boolean">true</is-current>
        <unit nil="true"/>
        <geo-entity>
          <iso-code2>NA</iso-code2>
          <name>Namibia</name>
          <type>COUNTRY</type>
        </geo-entity>
      </cites-quota>
      <cites-quota>
        <taxon-concept-id type="integer">4521</taxon-concept-id>
        <quota type="float">160.0</quota>
        <publication-date type="date">2014-03-14</publication-date>
        <notes>tusks as trophies from 80 animals</notes>
        <url nil="true"/>
        <public-display type="boolean">true</public-display>
        <is-current type="boolean">true</is-current>
        <unit nil="true"/>
        <geo-entity>
          <iso-code2>CM</iso-code2>
          <name>Cameroon</name>
          <type>COUNTRY</type>
        </geo-entity>
      </cites-quota>
    </cites-quotas>
    <cites-suspensions type="array">
      <cites-suspension>
        <taxon-concept-id nil="true"/>
        <notes>All commercial trade in specimens of CITES-listed species.</notes>
        <start-date type="date">2004-07-30</start-date>
        <is-current type="boolean">true</is-current>
        <applies-to-import type="boolean">false</applies-to-import>
        <geo-entity>
          <iso-code2>SO</iso-code2>
          <name>Somalia</name>
          <type>COUNTRY</type>
        </geo-entity>
        <start-notification>
          <name>CITES Notif. No. 2004/055</name>
          <date>2004-07-30</date>
          <url>http://www.cites.org/eng/notif/2004/055.pdf</url>
        </start-notification>
      </cites-suspension>
      <cites-suspension>
        <taxon-concept-id type="integer">4521</taxon-concept-id>
        <notes>The United States has suspended imports of sport-hunted trophies of African elephant taken in Zimbabwe on or after 4 April 2014.</notes>
        <start-date type="date">2014-08-11</start-date>
        <is-current type="boolean">true</is-current>
        <applies-to-import type="boolean">false</applies-to-import>
        <geo-entity>
          <iso-code2>ZW</iso-code2>
          <name>Zimbabwe</name>
          <type>COUNTRY</type>
        </geo-entity>
        <start-notification>
          <name>CITES Notif. No. 2014/037</name>
          <date>2014-08-11</date>
          <url>http://cites.org/sites/default/files/notif/E-Notif-2014-037.pdf</url>
        </start-notification>
      </cites-suspension>
    </cites-suspensions>
  </cites-legislation>
  EOS

  error code: 400, desc: "Bad Request"
  error code: 401, desc: "Unauthorized"
  error code: 404, desc: "Not Found"
  error code: 422, desc: "Unprocessable Entity"
  error code: 500, desc: "Internal Server Error"

  def index
    set_legislation_scope

    @taxon_concept = tc = TaxonConcept.hydrate(
      Rails.cache.fetch(
        cache_key_for(:taxon_concept), expires_in: 1.month
      ) do
        TaxonConcept.find(params[:taxon_concept_id]).as_json
      end
    )

    cites_listings, cites_suspensions, cites_quotas =
      Rails.cache.fetch(
        cache_key_for(:taxon_concept_associations, tc),
        expires_in: 1.month
      ) do
        [
          tc.cites_listings.in_scope(@legislation_scope).as_json,
          tc.cites_suspensions_including_global.in_scope(@legislation_scope).as_json,
          tc.cites_quotas_including_global.in_scope(@legislation_scope).as_json
        ]
      end


    @cites_listings = CitesListing.hydrate(cites_listings)
    @cites_suspensions = CitesSuspension.hydrate(cites_suspensions)
    @cites_quotas = Quota.hydrate(cites_quotas)
  end

  def permitted_params
    [:taxon_concept_id, :scope, :language, :format]
  end
end

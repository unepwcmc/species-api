class Api::V1::EuLegislationController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
    name 'EU Legislation'
  end

  api :GET, '/:taxon_concept_id/eu_legislation', 'Lists current EU annex listings, SRG opinions, and EU suspensions for a given taxon concept'

  description <<-EOS
==== eu_listings
[id] these records may cascade from higher taxonomic level, so this value is inherited and the same record may be returned in different contexts.
[taxon_concept_id] always present
[is_current] boolean flag indicating whether listing change is current
[annex] EU annex, one of <tt>A</tt>, <tt>B</tt>, <tt>C</tt>, <tt>D</tt>
[change_type] type of listing change, one of:
<tt>+</tt>: inclusion in annex,
<tt>-</tt>: removal from annex
[effective_at] date when listing change came into effect, YYYY-MM-DD
[party] where applicable, party involved in the listing change. See description of <tt>geo_entity</tt> object below.
[annotation] text of annotation (translated based on locale)
[hash_annotation] where applicable, <tt>#</tt> annotation (plants). See description of <tt>annotation</tt> object below.

==== eu_decisions
[id] these records may cascade from higher taxonomic level, so this value is inherited and the same record may be returned in different contexts.
[taxon_concept_id] always present
[notes]
[start_date] date when decision came into effect, YYYY-MM-DD
[is_current] boolean flag indicating whether decision is current
[eu_decision_type] type of decision. See description of eu_decision_type object below.
[geo_entity] geographic location to which the decision applies. See description of <tt>geo_entity</tt> object below.
[start_event] event that started the suspension. See description of <tt>event</tt> object below.
[end_event] event that ended the suspension. See description of <tt>event</tt> object below.
[source] source to which decision applies. See description of <tt>trade_code</tt> object below.
[term] term to which decision applies. See description of <tt>trade_code</tt> object below.

==== geo_entity
[iso_code2] ISO 3166-1 alpha-2
[name] name of country / territory (translated based on locale)
[type] one of <tt>COUNTRY</tt> or <tt>TERRITORY</tt>

==== trade_code
[code] CITES trade code
[name] full name name (translated based on locale)

==== event
[name] name of event
[date] date of event
[url] URL of document

==== annotation
[symbol] symbol of annotation
[note] text of annotation (translated based on locale)

==== eu_decision_type
[name] name of decision type, e.g. <tt>Suspension (a)</tt>, <tt>Negative</tt>, <tt>No opinion</tt>
[description] additional description where available
[type] one of <tt>SUSPENSION</tt>, <tt>POSITIVE_OPINION</tt>, <tt>NEGATIVE_OPINION</tt>, <tt>NO_OPINION</tt>
  EOS

  param :taxon_concept_id, String, :desc => "Taxon Concept ID", :required => true
  param :scope, String, desc: 'Time scope of legislation. Select all, current or historic. Defaults to current.', required: false
  param :language, String, desc: 'Select language for the text of legislation notes. Select en, fr, or es. Defaults to en.', required: false
  example <<-EOS
  {
    "eu_listings":[
      {
        "taxon_concept_id":4521,
        "is_current":true,
        "annex":"B",
        "change_type":"+",
        "effective_at":"2013-08-10",
        "annotation":"Populations of Botswana, Namibia, South Africa and Zimbabwe (listed in Annex B):\n\nFor the exclusive purpose of allowing: [...]"
      },
      {
        "taxon_concept_id":4521,
        "is_current":true,
        "annex":"A",
        "change_type":"+",
        "effective_at":"2013-08-10",
        "annotation":"All populations except those of Botswana, Namibia, South Africa and Zimbabwe."
      }
    ],
    "eu_decisions":[
      {
        "taxon_concept_id":4521,
        "notes":"",
        "start_date":"2014-09-03",
        "is_current":true,
        "eu_decision_type":{
          "name":"Positive",
          "description":null,
          "type":"POSITIVE_OPINION"
        },
        "geo_entity":{
          "iso_code2":"BW",
          "name":"Botswana",
          "type":"COUNTRY"
        },
        "start_event":{
          "name":"No 338/97",
          "date":"1997-06-01",
          "url":"http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=CONSLEG:1997R0338:20080411:EN:PDF"
        },
        "source":{
          "code":"W",
          "name":"Wild"
        },
        "term":{
          "code":null,
          "name":null
        }
      },
      {
        "taxon_concept_id":4521,
        "notes":null,
        "start_date":"2011-12-02",
        "is_current":true,
        "eu_decision_type":{
          "name":"i)",
          "description":"no significant trade anticipated",
          "type":"NO_OPINION"
        },
        "geo_entity":{
          "iso_code2":"ET",
          "name":"Ethiopia",
          "type":"COUNTRY"
        },
        "start_event":{
          "name":"No 338/97",
          "date":"1997-06-01",
          "url":"http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=CONSLEG:1997R0338:20080411:EN:PDF"
        },
        "source":{
          "code":null,
          "name":null
        },
        "term":{
          "code":null,
          "name":null
        }
      },
      {
        "taxon_concept_id":4521,
        "notes":"Hunting trophies",
        "start_date":"2014-09-04",
        "is_current":true,
        "eu_decision_type":{
          "name":"Suspension (a)",
          "description":null,
          "type":"SUSPENSION"
        },
        "geo_entity":{
          "iso_code2":"CM",
          "name":"Cameroon",
          "type":"COUNTRY"
        },
        "start_event":{
          "name":"No 888/2014",
          "date":"2014-09-04",
          "url":"http://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX:32014R0888&from=EN"
        },
        "source":{
          "code":"W",
          "name":"Wild"
        },
        "term":{
          "code":null,
          "name":null
        }
      }
    ]
  }
  EOS

  example <<-EOS
  <?xml version="1.0" encoding="UTF-8"?>
  <eu-legislation>
    <eu-listings type="array">
      <eu-listing>
        <taxon-concept-id type="integer">4521</taxon-concept-id>
        <is-current type="boolean">true</is-current>
        <annex>B</annex>
        <change-type>+</change-type>
        <effective-at type="date">2013-08-10</effective-at>
        <annotation>Populations of Botswana, Namibia, South Africa and Zimbabwe (listed in Annex B):

  For the exclusive purpose of allowing: [...]</annotation>
      </eu-listing>
      <eu-listing>
        <taxon-concept-id type="integer">4521</taxon-concept-id>
        <is-current type="boolean">true</is-current>
        <annex>A</annex>
        <change-type>+</change-type>
        <effective-at type="date">2013-08-10</effective-at>
        <annotation>All populations except those of Botswana, Namibia, South Africa and Zimbabwe.</annotation>
      </eu-listing>
    </eu-listings>
    <eu-decisions type="array">
      <eu-decision>
        <taxon-concept-id type="integer">4521</taxon-concept-id>
        <notes></notes>
        <start-date type="date">2014-09-03</start-date>
        <is-current type="boolean">true</is-current>
        <eu-decision-type>
          <name>Positive</name>
          <description nil="true"/>
          <type>POSITIVE_OPINION</type>
        </eu-decision-type>
        <geo-entity>
          <iso-code2>BW</iso-code2>
          <name>Botswana</name>
          <type>COUNTRY</type>
        </geo-entity>
        <start-event>
          <name>No 338/97</name>
          <date>1997-06-01</date>
          <url>http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=CONSLEG:1997R0338:20080411:EN:PDF</url>
        </start-event>
        <source>
          <code>W</code>
          <name>Wild</name>
        </source>
        <term>
          <code nil="true"/>
          <name nil="true"/>
        </term>
      </eu-decision>
      <eu-decision>
        <taxon-concept-id type="integer">4521</taxon-concept-id>
        <notes nil="true"/>
        <start-date type="date">2011-12-02</start-date>
        <is-current type="boolean">true</is-current>
        <eu-decision-type>
          <name>i)</name>
          <description>no significant trade anticipated</description>
          <type>NO_OPINION</type>
        </eu-decision-type>
        <geo-entity>
          <iso-code2>ET</iso-code2>
          <name>Ethiopia</name>
          <type>COUNTRY</type>
        </geo-entity>
        <start-event>
          <name>No 338/97</name>
          <date>1997-06-01</date>
          <url>http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=CONSLEG:1997R0338:20080411:EN:PDF</url>
        </start-event>
        <source>
          <code nil="true"/>
          <name nil="true"/>
        </source>
        <term>
          <code nil="true"/>
          <name nil="true"/>
        </term>
      </eu-decision>
      <eu-decision>
        <taxon-concept-id type="integer">4521</taxon-concept-id>
        <notes>Hunting trophies</notes>
        <start-date type="date">2014-09-04</start-date>
        <is-current type="boolean">true</is-current>
        <eu-decision-type>
          <name>Suspension (a)</name>
          <description nil="true"/>
          <type>SUSPENSION</type>
        </eu-decision-type>
        <geo-entity>
          <iso-code2>CM</iso-code2>
          <name>Cameroon</name>
          <type>COUNTRY</type>
        </geo-entity>
        <start-event>
          <name>No 888/2014</name>
          <date>2014-09-04</date>
          <url>http://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX:32014R0888&amp;from=EN</url>
        </start-event>
        <source>
          <code>W</code>
          <name>Wild</name>
        </source>
        <term>
          <code nil="true"/>
          <name nil="true"/>
        </term>
      </eu-decision>
    </eu-decisions>
  </eu-legislation>
  EOS

  error code: 400, desc: "Bad Request"
  error code: 401, desc: "Unauthorized"
  error code: 404, desc: "Not Found"
  error code: 422, desc: "Unprocessable Entity"
  error code: 500, desc: "Internal Server Error"

  def index
    set_legislation_scope
    @taxon_concept = TaxonConcept.find(params[:taxon_concept_id])
    @eu_listings = @taxon_concept.eu_listings.in_scope(@legislation_scope)
    @eu_decisions = @taxon_concept.eu_decisions.in_scope(@legislation_scope)
  end

  def permitted_params
    [:scope, :language, :taxon_concept_id, :format]
  end
end

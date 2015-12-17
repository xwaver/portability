local CharacterInfobox={}

local HF = require("Module:HF")
local getArgs = require('Dev:Arguments').getArgs

-- Since this should only be evaluated once per pageview, it's now global
_G.vars = { Pagename = mw.title.getCurrentTitle().text }

--[[
---- PRIVATE METHODS
]]--
local function transition(funcName)
  -- This module's initial functions were made using InfoboxBuilder.
  -- As a result, most of them can't be invoked for Portable Infoboxes.
  -- To allow the existing code without rewriting it, this wrapper allows invocation.
	return function (frame)
		local args = getArgs(frame, { trim = true, removeBlanks = true })
		return CharacterInfobox[funcName](args, vars)
	end
end

local CitizenshipCheck = function( values, table )
  local output = ""
  local valueUpper = ""
  local valueLower = ""
  local pagename = tostring(mw.title.getCurrentTitle().text)

    for i, value in ipairs( values ) do
      if type( value ) ~= nil then
        valueUpper = HF.firstToUpper( HF.trim( value ) )
        valueLower = string.lower( HF.trim( value ) )

        if type( table.valid[valueUpper] ) ~= nil and table.valid[valueUpper] == true then
          output = output .. HF.CategoryLink( valueUpper, pagename, valueUpper ) .. ", "
        elseif type( table.substitutes[valueLower] ) == "string" then
          output = output .. HF.CategoryLink( table.substitutes[valueLower], pagename, valueUpper ) .. ", "
        else
          output = output .. value .. ", "
        end
      else
        output = output .. value
      end
    end

  return output
end

local WeightSubcategory = function( weight )
  local subcategory = ""
if
   weight < 100 then
    subcategory = 0
  elseif weight >= 100 and weight < 150 then
    subcategory = 100
  elseif weight >= 150 and weight < 200 then
    subcategory = 150
  elseif weight >= 200 and weight < 300 then
    subcategory = 200
  elseif weight >= 300 and weight < 400 then
    subcategory = 300
  elseif weight >= 400 and weight < 500 then
    subcategory = 400
  elseif weight >= 500 then
    subcategory = 500
  end

  return subcategory
end

local EyesCategory = function( eyes, vars )
  local output = ""

  local eyes   = HF.firstToUpper( eyes )
  local eyeslc = string.lower( eyes )

  if eyeslc == "none" or eyeslc == "n/a" or eyeslc == "no eyes" then
    eyes = "No Eyes"
  end

  if mw.site.stats.pagesInCategory( eyes .. " Eyes", "pages" ) > 0 then
    output = output .. HF.CategoryLink( eyes .. " Eyes", vars.Pagename, eyes )
  else
    output = output .. eyes
  end

  return output
end

local HairCategory = function( hair, vars )
  local output = ""

  local hair   = HF.firstToUpper( hair )
  local hairlc = string.lower( hair )

  if     hairlc == "gray" then
    hair = "Grey"
  elseif hairlc == "blonde" then
    hair = "Blond"
  elseif hairlc == "strawberry blonde" then
    hair = "Strawberry Blond"
  end

  if     hairlc == "bald" then
    output = HF.CategoryLink( hair, vars.Pagename, hair )
  elseif hairlc == "none" or hairlc == "no hair" then
    output = HF.CategoryLink( "No Hair", vars.Pagename, "No Hair" )
  else
    if mw.site.stats.pagesInCategory( hair .. " Hair", "pages" ) > 0 then
      output = HF.CategoryLink( hair .. " Hair", vars.Pagename, hair )
    else
      output = hair
    end
  end

  return output
end

local CategoriesFromKeywords = function( fieldValue, valid, exceptions, vars )
  local output = ""

  -- Field isn't blank
  if fieldValue ~= nil then

    -- Grab a valid pair and use it
    for validKey, validValue in pairs(valid) do

      -- If you find the validKey in the field, look more closely
      if string.find( string.lower(fieldValue), validKey ) ~= nil then

        -- Check if there are exceptions for the validKey
        if type(exceptions[validKey]) ~= "table" then

          -- There are no exceptions, just categorize using this validKey and move to the next validKey
          for valueKey, valueCategoryName in ipairs( validValue ) do

            output = output .. HF.CategoryLink( valueCategoryName, vars.Pagename, "" )

            end

          end
      end
    end
  end
  return output
end

--[[
---- PUBLIC METHODS
]]--
local vars = {}
-- These are the invocation-friendly calls.
-- These are backward from the normal '_' order, for legacy purposes.
CharacterInfobox._InfoButton = transition('InfoButton')
CharacterInfobox._InfoIcon = transition('InfoIcon')
CharacterInfobox._getTitle = transition('getTitle')
CharacterInfobox._MainImage = transition('MainImage')
CharacterInfobox._MainImageLabel = transition('MainImageLabel')
CharacterInfobox._RealName = transition('RealName')
CharacterInfobox._CurrentAlias = transition('CurrentAlias')
CharacterInfobox._Alignment = transition('Alignment')
CharacterInfobox._Identity = transition('Identity')
CharacterInfobox._Citizenship = transition('Citizenship')
CharacterInfobox._MaritalStatus = transition('MaritalStatus')
CharacterInfobox._Occupation = transition('Occupation')
CharacterInfobox._Characteristics = transition('Characteristics')
CharacterInfobox._Gender = transition('Gender')
CharacterInfobox._Height = transition('Height')
CharacterInfobox._Weight = transition('Weight')
CharacterInfobox._Eyes = transition('Eyes')
CharacterInfobox._Hair = transition('Hair')
CharacterInfobox._Skin = transition('Skin')
CharacterInfobox._UnusualFeatures = transition('UnusualFeatures')
CharacterInfobox._Origin = transition('Origin')
CharacterInfobox._Universe = transition('Universe')
CharacterInfobox._Sector = transition('Sector')
CharacterInfobox._Ctry = transition('Ctry')
CharacterInfobox._Creators = transition('Creators')
CharacterInfobox._OriginalPublisher = transition('OriginalPublisher')

function CharacterInfobox.InfoIcon( field )
	if HF.isempty( field.buttonsize ) then field.buttonsize = "10px" end
	local link = string.format(
		"[[File:Information-silk.png|%s|link=Click here for help with this field#%s]]",
		field.buttonsize,
		field.Label
	)
	return link
end

function CharacterInfobox.InfoButton( field, vars )
  if HF.isempty( field.buttonsize ) then field.buttonsize = "10px" end
	local link = string.format(
		"[[File:Information-silk.png|%s|link=Click here for help with this field#%s]]",
		field.buttonsize,
		field.Label
	)
	local out = mw.html.create('span')
		:css('line-height','normal'):css('float','left'):css('position','relative'):css('top','4px')
		:wikitext(link):done()
		:tag('span'):css('float','left'):css('position','relative'):css('left','5px')
		:wikitext(field.Label):done()
  return tostring(out)
end

function CharacterInfobox.getTitle( field, vars )
  local title = field.Value

  if not HF.isempty(field.Title) then
    title = field.Title
  elseif not HF.isempty(field.CurrentAlias) then
    title = field.CurrentAlias
  elseif not HF.isempty(field.CurrentAliasRef) then
    title = field.CurrentAliasRef
  elseif not HF.isempty(field.RealName) then
    title = field.RealName
  end

  local link = '<span style="position:relative; float:right; font-size:70%;">[[File:Help.png|link=Help:Template Fields#Character Template|Character Template Help]]</span>'
  local titleObj = mw.title.new( title )

  if type(titleObj) ~= "nil" then
    if titleObj.exists then
      link = link .. HF.Link( title, "" )
    else
      link = link .. title
    end
  else
    link = link .. title
  end

  if HF.isempty( field.Death ) then
    link = link .. HF.CategoryLink( "Living Characters", vars.Pagename, "" )
  else
    link = link .. HF.CategoryLink( "Deceased Characters", vars.Pagename, "" )
  end

  return link
end

function CharacterInfobox.MainImage( field, vars )
  if HF.isempty( field.ImageText ) then field.ImageText = vars.Pagename end

  local output = '[[File:' .. field.Value .. '|center|' .. field.ImageText .. ']]'

  return output
end

function CharacterInfobox.MainImageLabel( field, vars )
  if HF.isempty( field.Gallery ) then field.Gallery = vars.Pagename .. "/Gallery" end

  return HF.Link( field.Gallery, field.Label )
end

function CharacterInfobox.RealName( field, vars )
  local output = ""

  if HF.isempty( field.ValueReal ) then
    output = field.Value
  else
    output = output .. " " .. field.ValueReal
  end

  if not HF.isempty( field.Value2 ) then
    output = output .. " " .. field.Value2
  end

  if not HF.isempty( field.ValueRef ) then
    output = output .. "" .. field.ValueRef
  end

  return output
end

function CharacterInfobox.CurrentAlias( field, vars )
  local output = field.Value
    if not HF.isempty( field.ValueRef ) then output = output .. "&nbsp;" .. field.ValueRef end
  return output
end

function CharacterInfobox.Alignment( field, vars )
  local output = ""
  local alignment = ""
  if not HF.isempty( field.Value ) then
    if field.Value:lower() == "evil" or field.Value:lower() == "bad" then
      alignment = "Bad"
    elseif field.Value:lower() == "neutral" then
      alignment = "Neutral"
    elseif field.Value:lower() == "good" then
      alignment = "Good"
    end
    output = HF.CategoryLink( alignment .. " Characters", vars.Pagename, alignment )
  else
    output = ""
  end

  return output
end

function CharacterInfobox.Identity( field, vars )
  local output = ""
  if not HF.isempty( field.Value ) then
    local category = field.Value .. " Identity"
    output = HF.CategoryLink( category, vars.Pagename, category )
  end
  if not HF.isempty( field.Value2 ) then
    output = output .. " " .. field.Value2
  end
  return output
end

function CharacterInfobox.Citizenship( field, vars )
  local ctznTable    = require('Module:Citizenship')
	local output = ""

  if not HF.isempty( field.Value ) then
    output = output .. CitizenshipCheck( HF.explode( ",", field.Value), ctznTable )
  end

  if not HF.isempty( field.Value2 ) then
    output = output .. CitizenshipCheck( HF.explode( ",", field.Value2), ctznTable )
  end

  if string.sub( output, -2, -1 ) == ", " then
    output = string.sub( output, 1, -3 ) -- Remove last comma and space
  end

  if string.sub( output, -1, -1 ) == "," then
    output = string.sub( output, 1, -2 ) -- Remove last comma
  end

  return output
end

function CharacterInfobox.MaritalStatus( field, vars )
  local statuses = HF.explode( ";", field.Value )

  local output = ""

  for i, status in ipairs( statuses ) do
    if string.lower(status) == "married" or string.lower(status) == "remarried" then
      output = output .. HF.CategoryLink( "Married Characters", vars.Pagename, status )
    else
      output = output .. HF.CategoryLink( status .. " Characters", vars.Pagename, status )
    end
  end

  if not HF.isempty( field.Value2 ) then
		output = output .. " " .. field.Value2
	end

  return output
end

function CharacterInfobox.Occupation( field, vars )
  local occupations = require('Module:CharacterInfoboxOccupation')
  local output = field.Value

  for key, value in pairs(occupations) do
    if string.find( string.lower(field.Value), key ) ~= nil then
      for i, category in ipairs( value ) do
        output = output .. HF.CategoryLink( category, vars.Pagename, "" )
      end
    end
  end

  return output
end

function CharacterInfobox.Characteristics( field, vars )
  local output = field.Value
  if not HF.isempty( field.CharRef ) then
    output = output .. field.CharRefTag
  end
  return output
end

function CharacterInfobox.Gender( field, vars )
  local category = field.Value .. " Characters"
	if HF.isempty( field.Value2 ) then
		field.Value2 = ''
	end
  return HF.CategoryLink( category, vars.Pagename, field.Value ) .. field.Value2 or ''
end

function CharacterInfobox.Height( field, vars )
  local output    = ""
  local valid     = false -- to check if the height (in ft.) is in a valid format
  local validInch = false -- to check if the height (in inches) is in a valid format
  local delimiter = ""

    if string.find( field.Value, "'" ) ~= nil then
      valid     = true
      delimiter = "'"
    elseif string.find( field.Value, "ft" ) ~= nil then
      valid     = true
      delimiter = "ft"
    end

    if valid == true then
      local heightExploded = HF.explode( delimiter, field.Value )

      local feet           = string.match( tostring( heightExploded[1] ), "%d+" )
      local inches         = string.match( tostring( heightExploded[2] ), "%d+" )

      if feet == nil then
        feet = "0"
      end
      if inches == nil then
        inches = "0"
      end


      local heightValid    = feet .. "\' " .. inches .. "\""
      local feetPadded     = HF.AddZeros( feet, 5 )
      local inchesPadded   = HF.AddZeros( inches, 2 )
      local heightPadded   = feetPadded .. "\' " .. inchesPadded .. "\""

      local footCategory    = "Height " .. feet .. "'"
      local inchesCategory  = "Height " .. heightValid

      local from           = mw.uri.encode( "%20" .. feetPadded .. "'" .. inchesPadded .. "\"", "PATH" )
      local category       = tostring( mw.uri.canonicalUrl( ":Category:Height", "from=" .. from ) )

      -- Link to Height Category with from= parameter
      output = HF.ExternalLink( category, heightValid, true )

      -- All into Height Category, sorted by Height and then Pagename
      output = output .. HF.CategoryLink( "Height", heightPadded .. vars.Pagename, "" )

      -- All of the same 'Feet' into appropriate Foot category, sorted by inches then pagename.
      output = output .. HF.CategoryLink( footCategory, inchesPadded .. vars.Pagename, "" )

      -- All of the same inches in the same feet category, sorted by pagename.
      output = output .. HF.CategoryLink( inchesCategory, vars.Pagename, "" )

      -- Concat Height2
			if not HF.isempty( field.Value2 ) then
				output = output .. " " .. field.Value2
			end

    else
			if HF.isempty( field.Value2 ) then
				field.Value2 = ''
			end
      output = field.Value .. " " .. field.Value2
    end

  return output
end

function CharacterInfobox.Weight( field, vars )
  local output = ""
  local Units  = require('Module:Units')
  local unit   = ""

  if string.find( field.Value, "lbs" ) then
    unit = "lbs"
  elseif string.find( field.Value, "kg" ) then
    unit = "kg"
  elseif string.find( field.Value, "ton" ) then
    unit = "ton"
  else
    unit = ""
  end

  if unit ~= "" then
    local weight    = tonumber( string.match( field.Value, "%d+" ) )
    local weightLbs = HF.round( weight * Units[unit].lbs , 0 )
    local weightKg  = HF.round( weight * Units[unit].kg , 0 )

    local weightValid = weightLbs .. " lbs (" .. weightKg .. " kg)"

    local subcategory      = WeightSubcategory( weightLbs )

    local parameter = "from="

    if subcategory == 0 then
      parameter   = "until="
      subcategory = 100
    end

    local category    = tostring( mw.uri.canonicalUrl( ":Category:Weight", parameter .. HF.AddZeros( subcategory, 5 ) ) )

    output = HF.ExternalLink( category, weightValid, true )

    output = output .. HF.CategoryLink( "Weight", "Weight " .. weightLbs, "" )

		if not HF.isempty( field.Value2 ) then
			output = output .. " " .. field.Value2
		end
  else
		if HF.isempty( field.Value2 ) then
			field.Value2 = ''
		end
    output = field.Value .. " " .. field.Value2
  end

  return output
end

function CharacterInfobox.Eyes( field, vars )
  local output = ""

    output = output .. EyesCategory( field.Value, vars )
		if not HF.isempty( field.Value2 ) then
			output = output .. " " .. EyesCategory( field.Value2, vars )
		end


  return output
end

function CharacterInfobox.Hair( field, vars )
  local output = ""

  output = output .. HairCategory( field.Value, vars )

  if not HF.isempty( field.Value2 ) then
    output = output .. " " .. field.Value2
  end

  return output
end

function CharacterInfobox.Skin( field, vars )
  local output = ""
  local skin   = HF.firstToUpper( field.Value )
    if string.lower( skin ) == "none" or string.lower( skin ) == "n/a" then
      output = output .. HF.CategoryLink( "No Skin", vars.Pagename, "No Skin" )
    else
      output = output .. HF.CategoryLink( skin .. " Skin", vars.Pagename, skin )
    end
		if not HF.isempty( field.Value2 ) then
	    output = output .. field.Value2
	  end

  return output
end

function CharacterInfobox.UnusualFeatures( field, vars )
  local output = field.Value

  local unusualFeatures = require('Module:CharacterInfoboxUnusualFeatures')
  local valid = unusualFeatures.valid
  local exceptions = unusualFeatures.exceptions

  output = output .. CategoriesFromKeywords( field.Value, valid, exceptions, vars )

  return output
end

function CharacterInfobox.Origin( field, vars )
  local output = field.Value

  local origins = require('Module:CharacterInfoboxOrigins')
  local valid = origins.valid
  local exceptions = origins.exceptions

  output = output .. CategoriesFromKeywords( field.Value, valid, exceptions, vars )

  return output
end

function CharacterInfobox.Universe( field, vars )
  local output = ""
  local UniverseNo    = string.match( field.Value, "%d+" )
  local UniverseTRN   = string.match( string.lower( field.Value ), "trn" )
	local UniverseBW    = string.match( string.lower( field.Value ), "bw" )
  local UniverseValid = ""

  if UniverseNo ~= nil then
    if UniverseTRN ~= nil then
      UniverseValid = "Earth-TRN" .. UniverseNo
		else if UniverseBW ~= nil then
			UniverseValid = "Earth-BW" .. UniverseNo
    else
      UniverseValid = "Earth-" .. UniverseNo
    end

    output = output .. HF.Link( UniverseValid )
    output = output .. HF.CategoryLink( UniverseValid .. " Characters", vars.Pagename, "" )
  else
    output = output ..HF.Link( field.Value )
    output = output .. HF.CategoryLink( field.Value .. " Characters", vars.Pagename, "" )
  end

  if not HF.isempty( field.Value2 ) then
    output = output .. " " .. field.Value2
  end

  if not HF.isempty( field.ValueRef ) then
    output = output .. " " .. field.ValueRef
  end

  return output
end

function CharacterInfobox.Sector( field, vars )
  local output =HF.Link( field.Value, "Sector " .. field.Value )
  if string.find( vars.Theme, "greenlantern" ) ~= nil then
    output = output .. HF.CategoryLink( "Green Lantern Corps member", vars.Pagename, "" )
  end
  return output
end

function CharacterInfobox.Ctry( field, vars )
  local substitutes = require('Module:CharacterInfoboxCtry')
  local output = ""

  if string.find( field.Value, "%[%[.+%]%]" ) == nil then
    if type( substitutes[field.Value] ) == "string" then
      output =HF.Link( substitutes[field.Value] )
    else
      output =HF.Link( field.Value )
    end
  else
    output = field.Value
  end

  return output
end

function CharacterInfobox.Creators( field, vars )
local output = ""
  local SC = require('Module:StaffCorrection')

  local creators = HF.explode( ";", field.Value )
  local creatorLink = ""

  for i, creator in ipairs( creators ) do
   if type( creator ) ~= nil then
    creatorLink = SC.Correction( HF.trim(creator) )
    output = output .. HF.CategoryLink( creatorLink .. "/Creator", vars.Pagename, "" )
    output = output ..HF.Link( creatorLink, creator ) .. ", "
    else
    output = output .. HF.CategoryLink ("Character Creators Needed", vars.Pagename, "" )
  end
 end

  if string.sub( output, -2, -1 ) == ", " then
    output = string.sub( output, 1, -3 ) -- Remove last comma and space
  end

  if string.sub( output, -1, -1 ) == "," then
    output = string.sub( output, 1, -2 ) -- Remove last comma
  end
	if not HF.isempty( field.Value2 ) then
		output = output .. " " .. field.Value2
	end
return output
end

function CharacterInfobox.OriginalPublisher( field, vars )
local output = field.Value

  if string.lower( field.Value ) ~= "dc" then
    output = output .. HF.CategoryLink( field.Value .. "Characters", vars.Pagename, "" )
  end

return output
end

return CharacterInfobox

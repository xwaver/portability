local Infobox = {}
local HF = require("Module:HF")
local getArgs = require('Dev:Arguments').getArgs
local MonthParse = require("Module:Month")
local lang = mw.language.new('en')

local StaffData = mw.loadData( 'Module:Staff/data' )
local ContributorNames = StaffData.ContributorNames

-- Since this should only be evaluated once per pageview, it's now global
_G.vars = { Pagename = mw.title.getCurrentTitle().text }

local function invokeInt(funcName)
  -- This wrapper allows invocation of an internal function from a frame.
	return function (frame)
		local args = getArgs(frame, { trim = true, removeBlanks = true })
		return Infobox[funcName](args, vars)
	end
end

Infobox.HeadTitle = invokeInt('_deriveHeadTitle')
Infobox.Image1 = invokeInt('_PrimaryCover')
Infobox.Image2 = invokeInt('_TextlessCover')
Infobox.ComicTitle = invokeInt('_deriveTitle')
Infobox.ReleaseDate = invokeInt('_releaseDate')
Infobox.PublicationDate = invokeInt('_publicationDate')

function Infobox._deriveHeadTitle( args, vars )
  local Title = mw.html.create('div'):addClass('comic-headtitle')
  local category = {}
  if not HF.isempty( args.HeadTitle ) then
    if string.lower( args.HeadTitle ) ~= 'none' then
       Title:tag('span'):addClass('comic-headtitle'):wikitext(args.HeadTitle):done()
     end
   end
  if not HF.isempty( args.StoryArc or args.StoryArc2 ) then
    local StoryArc = mw.html.create('div'):addClass('comic-subtitle')
    local ArcText = string.format('Part of the [[%s]]', args.StoryArc )
    table.insert( category, string.format( '[[Category:%s]]', args.StoryArc ))
    if not HF.isempty(args.StoryArc2) then
      ArcText = ArcText .. string.format(' and [[%s]] story arcs', args.StoryArc2 )
      table.insert( category, string.format( '[[Category:%s]]', args.StoryArc2 ))
    else
      ArcText = ArcText .. ' story arc'
    end
    StoryArc:wikitext(ArcText):done()
    Title:node( StoryArc )
  end
  if not HF.isempty( args.Event or args.Event2 ) then
    local Event = mw.html.create('div'):addClass('comic-subtitle')
    local EventText = string.format('Part of the [[%s]]', args.Event )
    if not HF.isempty(args.Event2) then
      EventText = EventText .. string.format(' and [[%s]] events', args.Event2 )
    else
      EventText = EventText .. ' event'
    end
    Event:wikitext(EventText):done()
    Title:node( Event )
  end
  if not HF.isempty( args.Storyline ) then
    local Storyline = mw.html.create('div'):addClass('comic-subtitle')
      :wikitext(string.format('Part of the [[%s]] storyline.', args.Storyline )):done()
    table.insert( category, string.format( '[[Category:%s]]', args.Storyline ))
    Title:node( Storyline )
  end
  Title:tag('div'):addClass('comic-subtitle'):tag('br', { selfClosing = true }):done()
  return tostring(Title) .. table.concat( category )
end

function Infobox._PrimaryCover( args, vars )
  local givenImage = args.Image or nil
  local fromPage = 'File:' .. vars.Pagename .. '.jpg'
  local label = args.ImageText or 'Cover'
  if mw.title.new( 'File', givenImage ).exists == true then
    return 'File:' .. givenImage .. '{{!}}' .. label
  elseif mw.title.new( 'File', fromPage).exists == true then
    return 'File:' .. fromPage .. '{{!}}' .. label
  else
    return nil
  end
end

function Infobox._TextlessCover( args, vars )
  local givenImage = args.Image2 or nil
  local fromPage = 'File:' .. vars.Pagename .. ' Textless.jpg'
  if mw.title.new( 'File', givenImage ).exists == true and givenImage then
    return 'File:' .. givenImage .. '{{!}} Textless'
  elseif mw.title.new( 'File', fromPage).exists == true then
    return 'File:' .. fromPage .. '{{!}} Textless'
  elseif mw.title.new( 'File', givenImage ).exists == true then
    return 'File:' .. givenImage .. '{{!}} ' ..args.Image2Text
  else return nil
  end
end

function Infobox._deriveTitle( args, vars )
  local Title, Volume, Issue  = string.match( vars.Pagename, "(.*)%s*Vol%s*(%d)%s*(%d*)")
   Title = args.Title or Title or nil
   Volume = args.Volume or Volume or nil
   Issue = args.Issue or Issue or nil
   if Title and Volume and Issue then
       return string.format('[[%s Vol %s]] # %s', Title, Volume, Issue)
   else
       return ''
   end

  end

function Infobox._releaseDate( args, vars )
	local ReleaseDate = args.ReleaseDate
	local ReleaseWeek = args.ReleaseWeek
	local output = ""
  if mw.title.new( 'Category', ReleaseDate ) then
    output = string.format( '[[:Category:%s|%s]]', ReleaseDate, lang:formatDate( 'F j, Y', ReleaseDate ) )
  elseif mw.title.new( 'Category', ReleaseWeek ) then
    output = string.format( '[[:Category:%s|%s]]', ReleaseWeek, lang:formatDate( 'F j, Y', ReleaseDate ) )
  else
    output = lang:formatDate( 'F j, Y', ReleaseDate )
  end
  return output
end

function Infobox._publicationDate( args, vars )
	local links = {}
  local Month, Year = args.Month or nil, args.Year or nil
	local gMonth = args.Month or nil
	local Season = args.Season or nil
	if Month then
		if string.find( gMonth, 'Late' ) then
			Month = string.match( gMonth, "Late(.*)" )
			table.insert( links,
				string.format( '[[:Category:%s, %s|%s]]', Year, Month, gMonth )
			)
			table.insert( links, ', ' )
		elseif string.find( gMonth, 'Early' ) then
			Month = string.match( gMonth, "Early(.*)" )
			table.insert( links,
				string.format( '[[:Category:%s, %s|%s]]', Year, Month, gMonth )
			)
			table.insert( links, ', ' )
		elseif string.find( gMonth, 'Mid' ) then
			Month = string.match( gMonth, "Mid(.*)" )
			table.insert( links,
				string.format( '[[:Category:%s, %s|%s]]', Year, Month, gMonth )
			)
			table.insert( links, ', ' )
		elseif string.find( gMonth, 'x' ) then
			Month = string.match( gMonth, "(.*)x" )
			table.insert( links,
				string.format( '[[:Category:%s, %s|%s]]', Year, Month, gMonth )
			)
			table.insert( links, ', ' )
		elseif Year then
			table.insert( links,
				string.format( '[[:Category:%s, %s|%s]]', Year, MonthParse(gMonth), MonthParse(gMonth .. 'x') )
			)
			table.insert( links, ', ' )
		elseif not Year then
			table.insert( links, MonthParse(gMonth .. x) )
		end
	end
	if not Season and not Year then
		table.insert( links,
			string.format( '[[:Category:%s, %s|%s]]', Year, MonthParse( Season ), Season )
		)
		table.insert( links, ', ' )
	end
	if Season and not Year then table.insert( links, Season ) end
	if Year then
		table.insert( links,
			string.format( '[[:Category:%s|%s]]', Year, Year )
		)
	end
	return table.concat( links )
end

Infobox.CreditCheck = invokeInt('_CreditCheck')
Infobox.Contributors = invokeInt('_Contributors')
Infobox.UContributors = invokeInt('_UContributors')

function Infobox._CreditCheck( parameters )
    local field = {
        testagainst = parameters[1],
        uncredited = parameters[2] or 'Uncredited'
    }
    if string.match( testagainst, 'redited') or
    string.match( string.lower( testagainst ), 'n/a') then
        return uncredited
    else
        return nil
    end
end


function Infobox._Contributors( parameters )
	local field = {
	    min = tonumber(parameters['Contributors.min']),
	    max = tonumber(parameters['Contributors.max']),
	    prefix = parameters['Contributors.prefix'],
	    role = parameters['Contributors.role'],
	    between = parameters['Contributors.between'],
	    }
	local output = {}
	if field.min and field.max then
		for i = field.min, field.max do
			local argument = field.prefix .. i
			local next = i + 1
			local nextargument = field.prefix .. next
			if parameters[argument] then -- Value exists
			    local keyname = string.lower(parameters[argument])
				local correction = ContributorNames.keyname or parameters[argument]
				table.insert( output, string.format('[[%s|%s]]', correction, parameters[argument]) )
				if field.role then table.insert( output, string.format(' [[Category:%s/%s]]', correction, field.role) ) end
			end
			if next < field.max and parameters[nextargument] and field.between then
				table.insert( output, field.between )
			end
		end
	elseif parameters[field.prefix] then
			    local keyname = string.lower(parameters[argument])
				local correction = ContributorNames.keyname or parameters[argument]
		table.insert( output, string.format('[[%s|%s]] [[Category:%s/%s]]', correction, field.prefix, correction, field.role) )
	end
	return table.concat( output )
end

function Infobox.UContributors( parameters )
	local field = {
	    min = parameters['Contributors.min'],
	    max = parameters['Contributors.max'],
	    prefix = parameters['Contributors.prefix'],
	    role = parameters['Contributors.role'],
	    between = parameters['Contributors.between'],
	    }
	local output = {}
	if field.min and field.max then
		for i = field.min, field.max do
			local argument = field.prefix .. i
			local next = i + 1
			local nextargument = field.prefix .. next
			if parameters[argument] then
				table.insert( output, string.format('[[%s|%s]]', parameters[argument], parameters[argument]) )
				if field.role then table.insert( output, string.format(' [[Category:%s/%s]]', parameters[argument], field.role) ) end
			end
			if next < field.max and parameters[nextargument] and field.between then
				table.insert( output, field.between )
			end
		end
	elseif parameters[field.prefix] then
		table.insert( output, string.format('[[%s|%s]] [[Category:%s/%s]]', parameters[argument], field.prefix, parameters[argument], field.role) )
	end
	return table.concat( output )
end

return Infobox

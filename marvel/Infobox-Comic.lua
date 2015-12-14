local Infobox = {}
local HF = require("Module:HF")
local getArgs = require('Dev:Arguments').getArgs
local lang = mw.language.new('en')

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
      ArcText = ArcText . string.format(' and [[%s]] story arcs', args.StoryArc2 )
      table.insert( category, string.format( '[[Category:%s]]', args.StoryArc2 ))
    else
      ArcText = ArcText . ' story arc'
    end
    StoryArc:wikitext(ArcText):done()
    Title:node( StoryArc )
  end
  if not HF.isempty( args.Event or args.Event2 ) then
    local Event = mw.html.create('div'):addClass('comic-subtitle')
    local EventText = string.format('Part of the [[%s]]', args.Event )
    if not HF.isempty(args.Event2) then
      EventText = EventText . string.format(' and [[%s]] events', args.Event2 )
    else
      EventText = EventText . ' event'
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
  else if mw.title.new( 'File', fromPage).exists == true then
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
  else if mw.title.new( 'File', fromPage).exists == true then
    return 'File:' .. fromPage .. '{{!}} Textless'
  else if mw.title.new( 'File', givenImage ).exists == true then
    return 'File:' .. givenImage .. '{{!}} ' ..args.Image2Text
  else return nil
  end
end

function Infobox._deriveTitle( args, vars )
  local Title, Volume, Issue  = string.match( vars.Pagename, "(.*)%s*Vol%s*(%d)%s*(%d*)")
   Title = args.Title or Title
   Volume = args.Volume or Volume
   Issue = args.Issue or Issue
  return string.format('[[%s Vol %s]] # %s', Title, Volume, Issue)
  end

function Infobox._releaseDate( args, vars )
  if mw.title.new( 'Category', args.ReleaseDate ) then
    return string.format( '[[:Category:%s|%s]]' args.ReleaseDate, lang:formatDate( 'F j, Y', args.ReleaseDate ) )
  else if mw.title.new( 'Category', args.ReleaseWeek ) then
    return string.format( '[[:Category:%s|%s]]' args.ReleaseWeek, lang:formatDate( 'F j, Y', args.ReleaseDate ) )
  else
    return lang:formatDate( 'F j, Y', args.ReleaseDate )
  end
end

function Infobox._publicationDate(args, vars)
  local Month, Year = args.Month or nil, args.Year or nil
  if string.find(args.Month, 'Late') then
    Month = string.match( args.Month, "Late%s*(.*)" )
  else if string.find(args.Month, 'Early') then
    Month = string.match( args.Month, "Early%s*(.*)" )
  else if string.find(args.Month, 'Mid') then
     Month = string.match( args.Month, "Mid%s*(.*)" )
  else if string.find(args.Month, 'x') then
    Month = string.match(args.Month, "(.*)x")
  else
  end
    Month = lang:formatDate( 'F', Month )
  return string.format("[[:Category:%s, %s|%s]]", Year, Month, args.Month )
end

return Infobox

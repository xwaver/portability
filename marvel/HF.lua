function HF.HelpButton( frame )
	local args = getArgs( frame )
	return HF._HelpButton( args )
end

function HF._HelpButton( args )
  if HF.isempty( args.buttonsize ) then args.buttonsize = "10px" end
  local target = args.ArticleTarget or "Click here for help with this field"
	local link = string.format(
		"[[File:Information-silk.png|%s|link=Click here for help with this field#%s]] %s",
		args.buttonsize,
		args.Section or args.Label or '',
    args.Label or ''
	)
  return link
end
[[File:Information-silk.png|link=Marvel Database:Episode Template#Usage|Episode Template Help]]

function HF.InfoboxTitle(args)
  local link = string.format("[[%s|%s|link=%s#%s|%s]]", args.Dingbat, args.buttonsize, args.Template, args.Section, args.Label)
  local span = mw.html.create('span'):css('position','relative'):css('float', args.float or 'right'):css('font-size','70%'):wikitext(link):done()
  -- '<span style="position:relative; float:right; font-size:70%;">[[File:Help.png|link=Help:Template Fields#Character Template|Character Template Help]]</span>'
end

" https://thegreata.pe/articles/2020/07/11/vim-syntax-highlighting-for-sql-strings-inside-python-code/
unlet b:current_syntax

syn include @SQL syntax/sql.vim
" syntax match sqlPythonString
"       \ /"""\(\_.*SELECT\_.*\)"""/

"syntax region sqlPythonString
"      \ matchgroup=pythonString
"      \ start=/\(f\)\?\z('''\|"""\)\_.\{-}\(SELECT\)/
"      \ end=/\z1/
"      \ contains=@SQL
"      " \ matchgroup=pythonString

" syn keyword pythonString sqlPythonString containedin=BraceBlock
"
" Mostly working
"syntax match sqlPythonString /"""\_.\{-}\(SELECT\)\_.\{-}"""/ contains=sqlPythonString
"syntax region sqlPythonSql  start=/[^"""]/ end=/"""/ contained keepend contains=@SQL

" syntax match sqlPythonSql /"""\zs\_.\{-}CASE\_.\{-}\ze"""/ contained
" syntax region sqlPythonString start=/\z("""\)\_.*CASE/ end=/"""/ contains=sqlPythonSql

" OKOKOK this works, but can't exclude 3 "s
" syntax match sqlPythonSql /"""\zs\_[^"']*CASE\_[^"']*\ze"""/ contained containedin=pythonString contains=@SQL extend
" syntax match sqlPythonSql /"""\zs\_[^"]*\(SELECT\|CASE\|WHERE\|FROM\|OVER\)\_[^"]\_[^"]\_[^"]*\ze"""$/ contained containedin=pythonString contains=@SQL
" Best so far
" syntax match sqlPythonSql /"""\C\zs\_.*CASE\_.\{-}\ze"""/ contained containedin=pythonString contains=@SQL extend
" syntax match sqlPythonSql /\('''\|"""\)\C\zs\_.\{-}\(SELECT\|CASE\|WHERE\|FROM\|OVER\)\_.\{-}\ze\('''\|"""\)/ contained containedin=pythonString,pythonFString contains=@SQL

" attempting 2 level match
" syntax match sqlPythonString keepend /"""\zs\_.\{-}\ze"""/ contained containedin=pythonString,pythonFString contains=sqlPythonSql
" syntax match sqlPythonSql keepend /"\zs\C\_.\{-}SELECT\_.\{-}\ze"/ contained containedin=pythonString
"
" attempting nextgroup
"syntax match sqlPythonString skipnl /"""/ contained containedin=pythonString,pythonFString nextgroup=sqlPythonSql
"syntax match sqlPythonSql /\_.\{-}SELECT/ contained

" offsets
" syntax region sqlPythonString
"       \ keepend
"       "\ matchgroup=pythonString
"       \ start=/"""\_[^"]*SELECT\_[^"]*/
"       \ end=/"""/
"       \ containedin=pythonString

" syntax match sqlPythonString keepend /\("""\|'''\)\zs\_.\{-}\ze\("""\|'''\)/ contained containedin=pythonString contains=sqlPythonSql extend transparent
" syntax region sqlPythonString keepend matchGroup=pythonString start=/\z("""\|'''\)/ end=/\z1/ contained containedin=pythonString contains=sqlPythonSql extend
" syntax match sqlPythonSql /\_.*\(SELECT\|CASE\|WHERE\|FROM\|OVER\)\_.*/ contained containedin=sqlPythonString contains=@SQL

" keepend really should work
"syntax region sqlPythonString
"      \ start=/"""\_.*SELECT/
"      \ end=/"""/
"      \ containedin=pythonString
"      \ contains=sqlPythonSql
"      \ keepend
"syntax match sqlPythonSql /"""\zs\_.*SELECT\_.*\ze"""/ contained
"

" syntax match sqlPythonString /"""\zs\_.\{-}\ze"""/ contained containedin=pythonString contains=sqlPythonSql keepend
" As good as it's going ot get
" syntax match sqlPythonSql /"""\_[^"]\{-}SELECT\_[^"]\{-}"""/ contained containedin=pythonString keepend
"syntax match sqlPythonSql /"""\zs\_[^"]\{-}\(SELECT\|CASE\|WHERE\|FROM\|OVER\)\_[^"]\{-}\ze"""/ contained containedin=pythonString,pythonFString keepend contains=@SQL
"syntax match sqlPythonSql /'''\zs\_[^']\{-}\(SELECT\|CASE\|WHERE\|FROM\|OVER\)\_[^']\{-}\ze'''/ contained containedin=pythonString,pythonFString keepend contains=@SQL

" syntax match sqlPythonSql /"""\@<=\_[^"]*SELECT\_.*"""/ contained containedin=pythonString keepend

" throwing in the towel
" syntax region sqlPythonString
"      \  matchgroup=pythonString
"       \ start=/\z("""\|'''\)--SQL/
"       \ end=/\z1/
"       \ contained
"       \ containedin=pythonString,pythonFString
"       \ contains=@SQL



" Getting close with negative lookaround
" syntax match sqlPythonSql /"""\_.\{-}\("""\)\@<!SELECT/ contained containedin=pythonString extend
" syntax match sqlPythonSql /"""\(\n\|.\)\{-}\("""\)\@<!SELECT\(\n\|.\)\{-}\("""\)\@<!"""/ contained containedin=pythonString
" syntax match sqlPythonSql /"""\(\n\|.\)\{-}\("""\)\@!SELECT/ contained containedin=pythonString
" syntax match sqlPythonSql /SELECT\(\n\|.\)\{-}\("""\)\@<!"""/ contained containedin=pythonString
"
" region with a lookbehind
" syntax region sqlPythonString
"       \ matchgroup=pythonString
"       \ start=/"""\(\_.\{-}\)\("""\)\@!SELECT/
"       \ end=/"""/
"       \ contained
"       \ containedin=pythonString,pythonFString
"
" syntax match sqlPythonSql /"""\_.\{-}\("""\)\@!SELECT\_.*\("""\)\@!/ contained containedin=pythonString

" Works unless there's a quote before select
" syntax region sqlPythonString
"       \ matchgroup=pythonString
"       \ start=/\C\z("""\|'''\)\(\_[^"]\{-}\(SELECT\|CASE\|OVER\)\)\@=/
"       \ end=/\z1/
"       \ contained
"       \ containedin=pythonString,pythonFString
"       \ contains=@SQL
"
"syntax region sqlPythonString
"      \ matchgroup=pythonString
"      \ start=/"""\%(\(\_.*\)\("""\)\@!\(SELECT\|"""\)\)\@=/
"      \ end=/"""/
"      \ contained
"      \ containedin=pythonString,pythonFString

"syntax region sqlPythonSql
"      \ matchgroup=pythonString
"      \ start=/"""/
"      \ end=/\(SELECT\|CASE\|OVER\)/
"      \ end=/"""/
"      \ contained
"      \ containedin=pythonString,pythonFString
" syntax match sqlPythonSql /"""\_.\{-}\("""\)\@!SELECT/ contained containedin=pythonString
" syntax match sqlPythonSql /"""\([^"][^"]\|[^"]"\|"[^"]\)*SELECT/ contained containedin=pythonString
" OMG
" syntax match sqlPythonSql /"""\(\_[^"]\|"\(""\)\@!\)*SELECT\_.*\("""\)\@!/ contained containedin=pythonString
" Even simpler
" syntax match sqlPythonSql /"""\(\_[^"]\|"\(""\)\@!\)*SELECT\_.\{-}"""/ contained containedin=pythonString
"
" hmm this isn't working yet
" syntax match sqlPythonSql /"""\(\_[^"]\|"\(""\)\@!\)*\(CASE\|ORDER\|SELECT\)\_.\{-}"""/ contained containedin=pythonString,pythonFString contains=@SQL
" syntax match sqlPythonSql /'''\(\_[^']\|'\(''\)\@!\)*\(CASE\|ORDER\|SELECT\)\_.\{-}'''/ contained containedin=pythonString,pythonFString contains=@SQL

" Perfect, but dies when scrolling around
" syntax match sqlPythonSql /\C"""\zs\(\_[^"]\|"\(""\)\@!\)\{-}\(CASE\|FROM\|SELECT\|OVER\)\_.\{-}\ze"""/ contained containedin=pythonString,pythonFString contains=@SQL
" syntax match sqlPythonSql /\C'''\zs\(\_[^']\|'\(''\)\@!\)\{-}\(CASE\|FROM\|SELECT\|OVER\)\_.\{-}\ze'''/ contained containedin=pythonString,pythonFString contains=@SQL
" syntax match sqlPythonSql /\C"""\zs\(\_.\("""\)\@!\)\{-}SELECT\(\_.\("""\)\@!\)\{-}\ze"""/ contained containedin=pythonString,pythonFString contains=@SQL
"
" slightly better
"syntax match sqlPythonSql /\C"""\zs\%([^"]\|\_.\%("""\)\@!\)\{-}\%(CASE\|FROM\|SELECT\|ORDER\|OVER\)\_.\{-}\ze"""/ contained containedin=pythonString,pythonFString contains=@SQL
"syntax match sqlPythonSql /\C'''\zs\%([^"]\|\_.\%('''\)\@!\)\{-}\%(CASE\|FROM\|SELECT\|ORDER\|OVER\)\_.\{-}\ze'''/ contained containedin=pythonString,pythonFString contains=@SQL
"syntax sync fromstart
" syn sync match pythonCommentSync grouphere NONE /"""/
" syn sync match pythonCommentSync groupthere pythonString /'''/

" WOOOOOOOOOOOOOOOOOOOOOOO
"  \C"""\(\(\_[^"]\|"\(""\)\@!\)\{-}\(SELECT\|CASE\|WHERE\|OVER\)\)\@=/
"  \C                 - case insensitive
"  """                - start with """
"  \(                 - start of zero-length match
"    \(
"      \_[^"]\|       - match any non " character
"      "\(""\)\@!     - or any " character not followed by ""
"    \)\{-}           - 
"    \(SELECT\|CASE\|WHERE\|OVER\)
"  \)\@=/             - everything up to here shouldn't count towards the start
syntax region sqlPythonString
      \ matchgroup=pythonString
      \ start=/\C"""\(\(\_[^"]\|"\(""\)\@!\)\{-}\(SELECT\|CASE\|WHERE\|OVER\)\)\@=/
      \ end=/"""/
      \ contained
      \ containedin=pythonString,pythonFString
      \ contains=@SQL
syntax region sqlPythonString
      \ matchgroup=pythonString
      \ start=/\C'''\(\(\_[^']\|'\(''\)\@!\)\{-}\(SELECT\|CASE\|WHERE\|OVER\)\)\@=/
      \ end=/'''/
      \ contained
      \ containedin=pythonString,pythonFString
      \ contains=@SQL
highlight sqlPythonSql guibg=#338833 ctermbg=236
highlight sqlPythonString guibg=#111111 ctermbg=236
let b:current_syntax = 'python'

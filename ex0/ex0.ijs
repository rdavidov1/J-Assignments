NB. Ravid Davidovich

NB. Read full file content
readFile =: 3 : 0
  1!:1 < y
)

NB. Split text into lines
SplitLines =: 3 : 0
  <;._2 y
)

NB. Global variables
inputDir =: ''
outputFile =: ''

NB. Append text to output file
WriteText =: 3 : 0
  y 1!:3 < outputFile
)

NB. Global totals
totalBuy =: 0
totalSell =: 0

NB. Handle buy command
HandleBuy =: 3 : 0
  'product amount price' =. y
  total =. amount * price
  totalBuy =: totalBuy + total
  '### BUY ', product, ' ###', LF, ": total
)

NB. Handle sell command
HandleSell =: 3 : 0
  'product amount price' =. y
  total =. amount * price
  totalSell =: totalSell + total
  '$$$ SELL ', product, ' $$$', LF, ": total
)

NB. Process one input line
ProcessLine =: 3 : 0
  cleanLine =. y -. CR
  words =. <;._1 ' ' , cleanLine

  command =. > 0 { words
  product =. > 1 { words
  amount  =. ". > 2 { words
  price   =. ". > 3 { words

  if. command -: 'buy' do.
    HandleBuy product ; amount ; price
  else.
    if. command -: 'sell' do.
      HandleSell product ; amount ; price
    end.
  end.
)

NB. Get file name without extension
GetFileTitle =: 3 : 0
  parts =. <;._1 '/' , y
  fullName =. > {: parts
  _3 }. fullName
)

NB. Get last folder name from path
GetLastFolderName =: 3 : 0
  parts =. <;._1 '/' , y
  > {: parts
)

NB. Process one vm file
ProcessFile =: 3 : 0
  lines =. SplitLines readFile y
  fileTitle =. GetFileTitle y

  WriteText fileTitle , LF

  for_line. lines do.
    WriteText ProcessLine > line
    WriteText LF
  end.
)

NB. Print totals to screen and file
PrintTotals =: 3 : 0
  line1 =. 'TOTAL BUY: ', ": totalBuy
  line2 =. 'TOTAL SELL: ', ": totalSell

  smoutput line1
  smoutput line2

  WriteText line1 , LF
  WriteText line2 , LF
)

NB. Main program
Main =: 3 : 0
  inputDir =: y
  folderName =. GetLastFolderName inputDir
  outputFile =: inputDir , '/' , folderName , '.asm'

  totalBuy =: 0
  totalSell =: 0

  '' 1!:2 < outputFile

  ProcessFile inputDir , '/InputA.vm'
  ProcessFile inputDir , '/InputB.vm'

  PrintTotals ''
)
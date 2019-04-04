<# License>------------------------------------------------------------

 Copyright (c) 2018 Shinnosuke Yakenohara

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>

-----------------------------------------------------------</License #>


#変数宣言
$opDebug = "/d" #デバッグモード指定文字列 

#変換指定Array
#("URI String","Local Address String")
$substitutions = @(
    ("https://www.google.com/", "D:\www.google.com\"),
    ("https://www.amazon.co.jp/", "D:\www.amazon.co.jp\")
)

# デバッグモード Optoin 確認ループ
$isDebug = $FALSE
$mxOfArgs = $Args.count
for ($idx = 0 ; $idx -lt $mxOfArgs ; $idx++){
    
    if($Args[$idx] -eq $opDebug){ #Recursive処理指定文字列の場合
        $isDebug = $TRUE
    }
}

#クリップボードからテキストを取得
$clipText = Get-Clipboard -Format Text

# 取得したモノがTextかどうかチェック
$nullOrEmpty = [String]::IsNullOrEmpty($clipText)
if($isDebug){
    Write-Host ("Clipboard text is null or empty:" + $nullOrEmpty)
}
if($nullOrEmpty){ #Text でない場合
    exit #終了
}

# 変換結果格納用Array
$convertedLines = New-Object System.Collections.Generic.List[System.String]

if($isDebug){
    Write-Host "Before:"
}

#変換ループ
$CRLF_splittedText = $clipText -split "`r`n"
foreach($oneOf_CRLF_splittedText in $CRLF_splittedText){
    
    $CRSplittedText = $oneOf_CRLF_splittedText -split "`r"
    foreach($oneOf_CRSplittedText in $CRSplittedText){

        $LFSplittedText = $oneOf_CRSplittedText -split "`n"
        foreach($oneOf_LFSplittedText in $LFSplittedText){

            if($isDebug){
                Write-Host $oneOf_LFSplittedText
            }

            #変換チェックループ
            foreach($oneOf_substitution in $substitutions){
                
                $escaped_oneOf_substitution_0 = [regex]::escape($oneOf_substitution[0])
                $escaped_oneOf_substitution_1 = [regex]::escape($oneOf_substitution[1])

                # URI String -> Local Directory String 変換可能な場合
                if($oneOf_LFSplittedText -match $escaped_oneOf_substitution_0){
                    $oneOf_LFSplittedText = $oneOf_LFSplittedText -replace $escaped_oneOf_substitution_0, $oneOf_substitution[1]
                    $oneOf_LFSplittedText = $oneOf_LFSplittedText -replace "/", "\"
                    break

                # Local Directory String -> URI String 変換可能な場合
                }elseif($oneOf_LFSplittedText -match $escaped_oneOf_substitution_1){
                    $oneOf_LFSplittedText = $oneOf_LFSplittedText -replace $escaped_oneOf_substitution_1, $oneOf_substitution[0]
                    $oneOf_LFSplittedText = $oneOf_LFSplittedText -replace "\\", "/"
                    break
                }
            }
            $convertedLines.Add($oneOf_LFSplittedText)
        }
    }
}

$convertedText = $convertedLines -join "`r`n" # 改行コードを CRLF で、連結

if($isDebug){
    Write-Host "After:"
    Write-Host $convertedText
}

#変換結果をクリップボードに保存
Set-Clipboard $convertedText

if($isDebug){
    Read-Host "Press Enter key to continue..."
}
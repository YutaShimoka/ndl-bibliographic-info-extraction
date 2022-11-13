# ndl-bibliographic-info-extraction

## 前提条件

国立国会図書館の[公式サイト](https://www.ndl.go.jp/index.html)から[国内刊行出版物の書誌情報（直近年1年分）](https://www.ndl.go.jp/jp/dlib/standards/opendataset/index.html)をダウンロードして `ndl-bibliographic-info-extraction/source` ディレクトリに置く。

## 使い方

**事前確認**

```bash
$ cd ndl-bibliographic-info-extraction

$ ls -1 source
## jm2020.txt
## jm2021.txt
```

**Shellを実行**

```bash
$ author_name="渡部昇一" # 任意の著者名

$ sh extract.sh ${author_name}
```

**事後確認**

```bash
$ ls -1 finished | grep ${author_name}
## jm2020_渡部昇一.tsv
## jm2021_渡部昇一.tsv

$ cat finished/jm2020_渡部昇一.tsv
## TITLE   SUB_TITLE       EDITION AUTHOR  PUBLISHER       PUBLISHED_DATE  ISBN_CODE
## これだけは知っておきたいほんとうの昭和史        -       -       渡部昇一 著     致知出版社      2020.3. 978-4-8009-1228-2
## 年表で読む日本近現代史  -       増補決定版.     渡部昇一 著     海竜社  2020.5. 978-4-7593-1714-5
## 語源でひもとく西洋思想史 = Etymology and Philosophy     -       -       渡部昇一 著     海竜社  2020.7. 978-4-7593-1724-4
## アングロ・サクソン文明落穂集. 10        -       -       渡部昇一 著     広瀬書院 ; 丸善出版 (発売)      2020.8. 978-4-906701-17-9
## 「時代」を見抜く力      渡部昇一的思考で現代を斬る      -       渡部昇一 著     育鵬社 ; 扶桑社 (発売)  2020.9. 978-4-594-08583-4
## 決定版・日本史  -       増補.   渡部昇一 著     育鵬社 ; 扶桑社 (発売)  2020.10.        978-4-594-08614-5

$ cat finished/jm2021_渡部昇一.tsv
## TITLE   SUB_TITLE       EDITION AUTHOR  PUBLISHER       PUBLISHED_DATE  ISBN_CODE
## 幸福なる人生ウォレス伝  渡部昇一遺稿    -       渡部昇一 著     育鵬社  2020.12 978-4-594-08487-5
## 渡部昇一の昭和史. 正    -       新装版  渡部昇一 著     ワック  2021.4  978-4-89831-838-6
## 昭和史の真実    -       -       渡部昇一 著     PHP研究所       2021.6  978-4-569-90138-1
## 歪められた昭和史        -       -       渡部昇一 著     ワック  2021.10 978-4-89831-854-6
## わが体験的キリスト教論  ドイツ留学で実感した西洋社会の本質      -       渡部昇一 著     ビジネス社      2021.11 978-4-8284-2342-5
```

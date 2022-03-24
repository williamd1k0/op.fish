function op
    set -l WIKI_HOST "https://onepiece.fandom.com"
    set -l WIKI_BASE "$WIKI_HOST/wiki"
    set -l HTML_FILTER "svg,script,img"
    # manga data
    set -l CH_VOL "div[data-source='vol'] div"
    set -l CH_TITLE "div[data-source='ename'] div"
    set -l CH_TITLE_JA "div[data-source='jname'] div"
    set -l CH_PAGES "div[data-source='page'] div"
    set -l CH_DATE "div[data-source='date2'] div"
    set -l CH_ARC "table th a[href\$='_Arc']"
    set -l CH_ANIME "div[data-source='anime'] div a"
    # volume data
    set -l VO_TITLE "h2[data-source='title']"
    set -l VO_CHAPTERS "div[data-source='chapters'] div"
    set -l VO_CHAPTERS_TITLES "div.mw-parser-output ul li a[href^='/wiki/Chapter_']"
    set -l VO_TITLE_JA "div[data-source='jname'] div"
    set -l VO_PAGES "div[data-source='jpage'] div"
    set -l VO_DATE "div[data-source='jdate'] div"
    # anime data
    set -l AN_TITLE "h2[data-source='Translation']"
    set -l AN_TITLE_JA "div[data-source='Kanji'] div"
    set -l AN_DATE "div[data-source='Airdate'] div"
    set -l AN_OP "td[data-source='Opening']"
    set -l AN_ED "td[data-source='Ending']"
    set -l AN_MANGA "div[data-source='chapter'] div a"

    argparse --name=op 'h/help' 'm/manga=+' 'v/volume=+' 'a/anime=+' 's/story-arc=' 'V' -- $argv
    if test -n "$_flag_help"
        echo "op 
    -m/--manga [number]
    -v/--volume [number]
    -a/--anime [number]
    -s/--story-arc [name]"
        return
    end

    function split_entries
        string replace -a " " "," $argv | string split ","
    end

    if test -n "$_flag_manga"
        for chapter in (split_entries $_flag_manga)
            set -l CH_DATA (curl -s "$WIKI_BASE/Chapter_$chapter" | htmlq "body" -r $HTML_FILTER)
            set_color brcyan -o
            printf "[Chapter $chapter | %s]\n" (echo "$CH_DATA" | htmlq "$CH_TITLE" -t)
            set_color normal
            printf "Title JP: %s\n" (echo "$CH_DATA" | htmlq "$CH_TITLE_JA" -t)
            printf "Date: %s\n" (echo "$CH_DATA" | htmlq "$CH_DATE" -t | string replace -r "\[\w+\]" "")
            printf "Volume: %s\n" (echo "$CH_DATA" | htmlq "$CH_VOL" -t)
            printf "Pages: %s\n" (echo "$CH_DATA" | htmlq "$CH_PAGES" -t)
            printf "Story Arc: %s\n" (echo "$CH_DATA" | htmlq "$CH_ARC" -t)
            set -l ANIME_VALUES (echo "$CH_DATA" | htmlq "$CH_ANIME" -t)
            if test -n "$ANIME_VALUES"
                printf "Anime:\n"
                for episode in $ANIME_VALUES
                    printf " - %s\n" "$episode"
                end
            end
            if test -n "$_flag_V"
                echo "[Refs]"
                printf " - Chapter URL: %s/Chapter_%s\n" "$WIKI_BASE" "$chapter"
                printf " - Story Arc URL: %s%s\n" "$WIKI_HOST" (echo "$CH_DATA" | htmlq "$CH_ARC" --attribute href)
            end
        end
    end
    if test -n "$_flag_volume"
        for volume in (split_entries $_flag_volume)
            set -l VO_DATA (curl -s "$WIKI_BASE/Volume_$volume" | htmlq "body" -r $HTML_FILTER)
            set_color brblue -o
            printf "[Volume $volume | %s]\n" (echo "$VO_DATA" | htmlq "$VO_TITLE" -t)
            set_color normal
            printf "Title JP: %s\n" (echo "$VO_DATA" | htmlq "$VO_TITLE_JA" -t)
            printf "Date: %s\n" (echo "$VO_DATA" | htmlq "$VO_DATE" -t | string replace -r "\[\w+\]" "")
            printf "Pages: %s\n" (echo "$VO_DATA" | htmlq "$VO_PAGES" -t)
            printf "Chapters: %s\n" (echo "$VO_DATA" | htmlq "$VO_CHAPTERS" -t)
            set -l CHAPTER_VALUES (echo "$VO_DATA" | htmlq "$VO_CHAPTERS_TITLES")
            if test -n "$CHAPTER_VALUES"
                for chapter in $CHAPTER_VALUES
                    set -l chapter_name (echo "$chapter" | htmlq a -t)
                    set -l chapter_number (echo "$chapter" | htmlq a --attribute href | string replace "/wiki/Chapter_" "")
                    if not string match -qr "$chapter_number\s*\$" "$chapter_name"
                        printf " - %s. %s\n" "$chapter_number" "$chapter_name"
                    end
                end
            end
            if test -n "$_flag_V"
                echo "$WIKI_BASE/Volume_$volume"
            end
        end
    end
    if test -n "$_flag_anime"
        for episode in (split_entries $_flag_anime)
            set -l AN_DATA (curl -s "$WIKI_BASE/Episode_$episode" | htmlq "body" -r $HTML_FILTER)
            set_color brgreen -o
            printf "[Episode $episode | %s]\n" (echo "$AN_DATA" | htmlq "$AN_TITLE" -t)
            set_color normal
            printf "Title JP: %s\n" (echo "$AN_DATA" | htmlq "$AN_TITLE_JA" -t)
            printf "Date: %s\n" (echo "$AN_DATA" | htmlq "$AN_DATE" -t | string replace -r "\[\w+\]" "")
            printf "Opening: %s\n" (echo "$AN_DATA" | htmlq "$AN_OP" -t)
            set -l ENDING_VALUE (printf "%s" "$AN_DATA" | htmlq "$AN_ED" -t)
            if test -n "$ENDING_VALUE"
                printf "Ending: %s\n" "$ENDING_VALUE"
            end
            set -l MANGA_VALUES (echo "$AN_DATA" | htmlq "$AN_MANGA" -t)
            if test -n "$MANGA_VALUES"
                printf "Manga:\n"
                for chapter in $MANGA_VALUES
                    printf " - %s\n" "$chapter"
                end
            end
            if test -n "$_flag_V"
                echo "$WIKI_BASE/Episode_$episode"
            end
        end
    end
    if test -n "$_flag_story_arc"
        set ARC_END_POINT (string replace -a " " "_" "$_flag_story_arc")
        if not string match -r "_Arc\$" "$ARC_END_POINT"
            set ARC_END_POINT "$ARC_END_POINT"_Arc
        end
        set -l ARC_URL "$WIKI_BASE/$ARC_END_POINT"
        if test -n "$_flag_V"
            echo $ARC_URL
        end
        set -e ARC_END_POINT
    end
    functions -e split_entries
end

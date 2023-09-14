//
//  EnRuNormalizer.swift
//  Synth
//
//  Created by Erdene-Ochir Tuguldur on 2022.12.19.
//

import Foundation
import SwiftyPyRegex

class EnRuNormalizer {
    private var enru2mn: [String: String] = [:]
    private var enru2mn_re: [String: String] = [:]
    init() {
        enru2mn["female1 The best way to predict the future, is to invent it."] = "сайн байна уу? эмэгтэй хоолой нэг";
        enru2mn["female2 The best way to predict the future, is to invent it."] = "сайн байна уу? эмэгтэй хоолой хоёр";
        enru2mn["female3 The best way to predict the future, is to invent it."] = "сайн байна уу? эмэгтэй хоолой гурав";
        enru2mn["male1 The best way to predict the future, is to invent it."] = "сайн байнуу эрэгтэй хоолой нэг";
        enru2mn["male2 The best way to predict the future, is to invent it."] = "сайн байнуу эрэгтэй хоолой хоёр";
        enru2mn["male3 The best way to predict the future, is to invent it."] = "сайн байнуу эрэгтэй хоолой гурав";
        enru2mn["female1 Не предсказывайте будущее — создавайте его.."] = "сайн байна уу? эмэгтэй хоолой нэг";
        enru2mn["female2 Не предсказывайте будущее — создавайте его."] = "сайн байна уу? эмэгтэй хоолой хоёр";
        enru2mn["female3 Не предсказывайте будущее — создавайте его."] = "сайн байна уу? эмэгтэй хоолой гурав";
        enru2mn["male1 Не предсказывайте будущее — создавайте его."] = "сайн байна уу? эрэгтэй хоолой нэг";
        enru2mn["male2 Не предсказывайте будущее — создавайте его."] = "сайн байна уу? эрэгтэй хоолой хоёр";
        enru2mn["male3 Не предсказывайте будущее — создавайте его."] = "сайн байна уу? эрэгтэй хоолой гурав";
        enru2mn["Hello! My name is female1."] = "сайн байна уу? эмэгтэй хоолой нэг";
        enru2mn["Hello! My name is female2."] = "сайн байна уу? эмэгтэй хоолой хоёр";
        enru2mn["Hello! My name is female3."] = "сайн байна уу? эмэгтэй хоолой гурав";
        enru2mn["Hello! My name is male1."] = "сайн байна уу? эрэгтэй хоолой нэг";
        enru2mn["Hello! My name is male2."] = "сайн байна уу? эрэгтэй хоолой хоёр";
        enru2mn["Hello! My name is male3."] = "сайн байна уу? эрэгтэй хоолой гурав";
        enru2mn["Здравствуйте! Меня зовут female1."] = "сайн байна уу? эмэгтэй хоолой нэг";
        enru2mn["Здравствуйте! Меня зовут female2."] = "сайн байна уу? эмэгтэй хоолой хоёр";
        enru2mn["Здравствуйте! Меня зовут female3."] = "сайн байна уу? эмэгтэй хоолой гурав";
        enru2mn["Здравствуйте! Меня зовут male1."] = "сайн байна уу? эрэгтэй хоолой нэг";
        enru2mn["Здравствуйте! Меня зовут male2."] = "сайн байна уу? эрэгтэй хоолой хоёр";
        enru2mn["Здравствуйте! Меня зовут male3."] = "сайн байна уу? эрэгтэй хоолой гурав";
        enru2mn["Привіт! Мене звуть female1."] = "сайн байна уу? эмэгтэй хоолой нэг";
        enru2mn["Привіт! Мене звуть female2."] = "сайн байна уу? эмэгтэй хоолой хоёр";
        enru2mn["Привіт! Мене звуть female3."] = "сайн байна уу? эмэгтэй хоолой гурав";
        enru2mn["Привіт! Мене звуть male1."] = "сайн байна уу? эрэгтэй хоолой нэг";
        enru2mn["Привіт! Мене звуть male2."] = "сайн байна уу? эрэгтэй хоолой хоёр";
        enru2mn["Привіт! Мене звуть male3."] = "сайн байна уу? эрэгтэй хоолой гурав";
        enru2mn["female1 Найкращий спосіб передбачити майбутнє — це винайти його."] = "сайн байна уу? эмэгтэй хоолой нэг";
        enru2mn["female2 Найкращий спосіб передбачити майбутнє — це винайти його."] = "сайн байна уу? эмэгтэй хоолой хоёр";
        enru2mn["female3 Найкращий спосіб передбачити майбутнє — це винайти його."] = "сайн байна уу? эмэгтэй хоолой гурав";
        enru2mn["male1 Найкращий спосіб передбачити майбутнє — це винайти його."] = "сайн байна уу? эрэгтэй хоолой нэг";
        enru2mn["male2 Найкращий спосіб передбачити майбутнє — це винайти його."] = "сайн байна уу? эрэгтэй хоолой хоёр";
        enru2mn["male3 Найкращий спосіб передбачити майбутнє — це винайти його."] = "сайн байна уу? эрэгтэй хоолой гурав";
        enru2mn["female1 Najbolji način za predviđanje budućnosti jest da ju se izumi."] = "сайн байна уу? эмэгтэй хоолой нэг";
        enru2mn["female2 Najbolji način za predviđanje budućnosti jest da ju se izumi."] = "сайн байна уу? эмэгтэй хоолой хоёр";
        enru2mn["female3 Najbolji način za predviđanje budućnosti jest da ju se izumi."] = "сайн байна уу? эмэгтэй хоолой гурав";
        enru2mn["male1 Najbolji način za predviđanje budućnosti jest da ju se izumi."] = "сайн байна уу? эрэгтэй хоолой нэг";
        enru2mn["male2 Najbolji način za predviđanje budućnosti jest da ju se izumi."] = "сайн байна уу? эрэгтэй хоолой хоёр";
        enru2mn["male3 Najbolji način za predviđanje budućnosti jest da ju se izumi."] = "сайн байна уу? эрэгтэй хоолой гурав";
        
        
        enru2mn["cyrillic small letter a"] = "а"; enru2mn["cyrillic capital letter a"] = "А";
        enru2mn["cyrillic small letter be"] = "б"; enru2mn["cyrillic capital letter be"] = "Б";
        enru2mn["cyrillic small letter ve"] = "в"; enru2mn["cyrillic capital letter ve"] = "В";
        enru2mn["cyrillic small letter ghe"] = "г"; enru2mn["cyrillic capital letter ghe"] = "Г";
        enru2mn["cyrillic small letter de"] = "д"; enru2mn["cyrillic capital letter de"] = "Д";
        enru2mn["cyrillic small letter "] = "е"; enru2mn["cyrillic capital letter "] = "Е";
        enru2mn["cyrillic small letter "] = "ё"; enru2mn["cyrillic capital letter "] = "Ё";
        enru2mn["cyrillic small letter zhe"] = "ж"; enru2mn["cyrillic capital letter zhe"] = "Ж";
        enru2mn["cyrillic small letter "] = "з"; enru2mn["cyrillic capital letter "] = "З";
        enru2mn["cyrillic small letter i"] = "и"; enru2mn["cyrillic capital letter i"] = "И";
        enru2mn["cyrillic small letter i with combining breve"] = "й";
        enru2mn["cyrillic capital letter i with combining breve"] = "Й";
        enru2mn["cyrillic small letter el"] = "л"; enru2mn["cyrillic capital letter el"] = "Л";
        enru2mn["cyrillic small letter em"] = "м"; enru2mn["cyrillic capital letter em"] = "М";
        enru2mn["cyrillic small letter en"] = "н"; enru2mn["cyrillic capital letter en"] = "Н";
        enru2mn["cyrillic small letter o"] = "о"; enru2mn["cyrillic capital letter o"] = "О";
        enru2mn["cyrillic small letter barred o"] = "ө"; enru2mn["cyrillic capital letter barred o"] = "Ө";
        enru2mn["cyrillic small letter pe"] = "п"; enru2mn["cyrillic capital letter pe"] = "П";
        enru2mn["cyrillic small letter er"] = "р"; enru2mn["cyrillic capital letter er"] = "Р";
        enru2mn["cyrillic small letter es"] = "с"; enru2mn["cyrillic capital letter es"] = "С";
        enru2mn["cyrillic small letter te"] = "т"; enru2mn["cyrillic capital letter te"] = "Т";
        enru2mn["cyrillic small letter u"] = "у"; enru2mn["cyrillic capital letter u"] = "У";
        enru2mn["cyrillic small letter straight u"] = "ү"; enru2mn["cyrillic capital letter straight u"] = "Ү";
        enru2mn["cyrillic small letter ef"] = "ф"; enru2mn["cyrillic capital letter ef"] = "Ф";
        enru2mn["cyrillic small letter ha"] = "х"; enru2mn["cyrillic capital letter ha"] = "Х";
        enru2mn["cyrillic small letter tse"] = "ц"; enru2mn["cyrillic capital letter tse"] = "Ц";
        enru2mn["cyrillic small letter che"] = "ч"; enru2mn["cyrillic capital letter che"] = "Ч";
        enru2mn["cyrillic small letter sha"] = "ш"; enru2mn["cyrillic capital letter sha"] = "Ш";
        enru2mn["cyrillic small letter "] = "щ"; enru2mn["cyrillic capital letter "] = "Щ";
        enru2mn["cyrillic small letter "] = "ъ"; enru2mn["cyrillic capital letter "] = "Ъ";
        enru2mn["cyrillic small letter soft sign"] = "ь"; enru2mn["cyrillic capital letter soft sign"] = "Ь";
        enru2mn["cyrillic small letter yeru"] = "ы"; enru2mn["cyrillic capital letter yeru"] = "Ы";
        enru2mn["cyrillic small letter e"] = "э"; enru2mn["cyrillic capital letter e"] = "Э";
        enru2mn["cyrillic small letter yu"] = "ю"; enru2mn["cyrillic capital letter yu"] = "Ю";
        enru2mn["cyrillic small letter ya"] = "я"; enru2mn["cyrillic capital letter ya"] = "Я";
        enru2mn["cyrillic small letter ka"] = "к"; enru2mn["cyrillic capital letter ka"] = "К";
        
        enru2mn["question mark"] = "асуултын тэмдэг"
        enru2mn["less than"] = "багын тэмдэг"
        enru2mn["greater than"] = "ихийн тэмдэг"
        enru2mn["colon"] = "давхар цэг"
        enru2mn["semicolon"] = "цэгтэй таслал"
        enru2mn["left single quotation mark"] = "дусал хаалт"; enru2mn["right single quotation mark"] = "дусал хаалт"
        enru2mn["left double quotation mark"] = "хос дусал хаалт"; enru2mn["right double quotation mark"] = "хос дусал хаалт"
        enru2mn["backslash"] = "бөхрөг зураас"
        enru2mn["vertical line"] = "босоо зураас"
        enru2mn["left brace"] = "их хаалт нээх"
        enru2mn["right brace"] = "их хаалт хаах"
        enru2mn["left bracket"] = "дунд хаалт нээх"
        enru2mn["right bracket"] = "дунд хаалт хаах"
        enru2mn["plus"] = "нэмэх тэмдэг"
        enru2mn["equals"] = "тэнцүүгийн тэмдэг"
        enru2mn["hyphen"] = "дундуур зураас"
        enru2mn["underscore"] = "доогуур зураас"
        enru2mn["left parenthesis"] = "бага хаалт нээх"
        enru2mn["right parenthesis"] = "бага хаалт хаах"
        enru2mn["star"] = "од"
        enru2mn["percent"] = "хувь тэмдэг"
        enru2mn["number"] = "чагт тэмдэг"
        enru2mn["exclamation mark"] = "анхааруулах тэмдэг"
        enru2mn["period"] = "цэг"
        enru2mn["comma"] = "таслал"
        enru2mn["caret"] = "малгай"
        enru2mn["slash"] = "налуу зураас"
        enru2mn["and"] = "ээнд"
        enru2mn["at"] = "ээт"
        enru2mn["tugrik sign"] = "төгрөгийн тэмдэг"
        enru2mn["dollar"] = "долларын тэмдэг"
        enru2mn["tilde"] = "долгио"
        enru2mn["numero sign"] = "дугаарлах тэмдэг"

        enru2mn["элемент регулировки"] = "control element"
        enru2mn["Кнопкапереключатель"] = "switch button"
        enru2mn["Кнопка-переключатель"] = "switch button"
        enru2mn["Кнопка указывающая назад"] = "back button"
        enru2mn["Кнопка, указывающая назад"] = "back button"
        enru2mn["указывающая назад"] = "back button"
        enru2mn["Кнопка"] = "button"
        enru2mn["выкл"] = "off"; enru2mn["выкл."] = "off"
        enru2mn["выключен"] = "off"; enru2mn["выключен."] = "off"
        enru2mn["вкл"] = "on"; enru2mn["вкл"] = "on"
        enru2mn["недоступно"] = "not available"
        enru2mn["выбрано"] = "selected"
        enru2mn["Объект меню статуса"] = "status menu object"
        enru2mn["Заголовок"] = "гарчиг"
        enru2mn["подчеркивание"] = "underscore"
        enru2mn["ссылка"] = "холбоос"
        enru2mn["Поле поиска"] = "search field"
        enru2mn["Текстовое поле"] = "text field"
        enru2mn["Защищенное текстовое поле"] = "protected text field"
        enru2mn["Домой"] = "home"
        enru2mn["Идет правка"] = "editing in progress"
        enru2mn["Вкладка"] = "tab"
        enru2mn["Полезная страничка"] = "usefull page"
        enru2mn["Русский (Россия)"] = "Монгол хэл"
        enru2mn["Коснитесь дважды, чтобы переключить настройку."] = "Tap twice to switch the setting."
        enru2mn["VoiceOver выключен"] = "VoiceOver off"
        enru2mn["Посещены"] = "visited"
        enru2mn["Изображение"] = "зураг"
        enru2mn["зображение"] = "зураг"
        enru2mn["маркер списка"] = "list marker"
        enru2mn["Веб-страница загружена"] = "The web page is loaded"
        enru2mn["Ориентир"] = "reference"
        enru2mn["Идет правка"] = "editing in progress"
        enru2mn["слова"] = "words"
        enru2mn["Cлова"] = "words"
        enru2mn["Уровень заголовка"] = "head level"
        enru2mn["Коснитесь дважды, чтобы редактировать."] = "double tap to edit"
        enru2mn["Используйте ротор для доступа к объекту: Misspelled Words"] = "Use the rotor to access the object: Misspelled Words"
        enru2mn["Объект меню статуса"] = "status meny object"
        enru2mn["Коснитесь дважды для активации инструмента выбора"] = "Double tap to activate selection too"
        enru2mn["Свернуто"] = "Collapsed"
        enru2mn["Коснитесь дважды, чтобы развернуть"] = "Double tap to expand"
        enru2mn["Всплывающее меню"] = "pop up menu"
        enru2mn["Всплывающая кнопка"] = "pop up button"
        enru2mn["Всплывающий блок списка"] = "pop up list"
        enru2mn["space"] = "зай"
        enru2mn["пробел"] = "зай"
        enru2mn["точка с запятой"] = "цэгтэй таслал"
        enru2mn["лист моакэ"] = "цэгтэй таслал"
        enru2mn["авторские права"] = "copyright"
        enru2mn["Смахните вверх или вниз одним пальцем, чтобы настроить значение."] = "Swipe up or down with one finger to adjust the value."
        
        
        // replace inside of text
        enru2mn_re["точка вставки в начале"] = "insertion point at start"
        enru2mn_re["точка с запятой"] = "цэгтэй таслал"
        enru2mn_re["точка вставки между из и"] = "insertion point between out and"
        enru2mn_re["точка"] = "цэг"
        enru2mn_re["точки"] = "цэг"
        enru2mn_re["маркер списка"] = "list marker"
        enru2mn_re["Уровень заголовка"] = "head level"
        enru2mn_re["процент"] = "хувь"
        enru2mn_re["Кнопкапереключатель"] = "switch button"
        enru2mn_re["Cлова."] = "words"
        enru2mn_re["в положении"] = "at position"
        enru2mn_re["Ориентир"] = "Reference point"
        enru2mn_re["собачка"] = " "
        enru2mn_re["ссылка конец строки"] = "линк мөрийн төгсгөл"
        enru2mn_re["вставки в начале"] = "inserts at the beginning"
        enru2mn_re["авторские права"] = "copyright"
        enru2mn_re["открывающая двойная кавычка"] = "хос дусал хаалт"
        enru2mn_re["заключительная двойная кавычка"] = "хос дусал хаалт"
        enru2mn_re["гравис"] = "backtick"
        enru2mn_re["знак тугрика"] = "төгрөг"

        //replace emoji
        enru2mn_re["широко улыбающееся лицо"] = "өргөн инээмсэглэсэн царай" //wide smiling face
        enru2mn_re["улыбающееся лицо"] = "инээмсэглэсэн царай" //smiling face
        enru2mn_re["подмигивающее лицо"] = "нүдээ ирмэсэн царай" //winking face
        enru2mn_re["широко улыбающееся лицо с зажмуренными глазами"] = "аньсан нүдтэй инээмсэглэсэн царай"//wide smiling face with closed eyes
        enru2mn_re["лицо со слезами счастья"] = "аз жаргалын нулимстай царай"//face with tears of happiness
        enru2mn_re["катаюсь по полу от смеха"] = "эргэлдэж инээж буй "//rolling on the floor laughing
        enru2mn_re["Лицо с глазами-сердечками"] = "Зүрхний нүдтэй царай"//Face with heart eyes
        enru2mn_re["улыбающееся лицо в сердечках"] = "Зүрхтэй инээмсгэлсэн царай"//smiling face with hearts
        enru2mn_re["посылающее воздушный поцелуй"] = "Үнсэлт үлээж буй"//blowing a kiss
        enru2mn_re["целующее лицо со счастливыми глазами"] = "аз жаргалтай нүдээр үнсэж буй царай"//kissing face with happy eyes
        enru2mn_re["подмигивающее лицо с высунутым языком"] = "хэлээ унжуулсан нүдээ ирмэж буй царай"//winking face with tongue hanging out
        enru2mn_re["широко улыбающееся лицо с косыми глазами и высунутым языком "] = "анивчсан нүд цухуйсан хэлтэй инээмсэглэсэн царай"//broadly smiling face with squinting eyes and protruding tongue
        enru2mn_re["ухмыляющееся лицо"] = "инээмсэглэсэн царай"//grinning face
        enru2mn_re["недовольное лицо"] = "дургүйцсэн царай"//displeased face
        enru2mn_re["хмурое лицо"] = "гунигтай царай"//gloomy face
        enru2mn_re["взволнованное лицо"] = "сэтгэл хөдөлсөн царай"//excited face
        enru2mn_re["расстроенное лицо с зажмуренными глазами"] = "нүдээ аниад бухимдсан царай"//frustrated face with closed eyes
        enru2mn_re["красное от злости лицо"] = "уурандаа улайсан царай"//face red with anger
        enru2mn_re["потеющее от жары лицо с высунутым языком"] = "хэл нь цухуйсан хөлстэй царай"//sweaty face with protruding tongue
        enru2mn_re["обнимающее лицо с улыбкой и счастливыми глазами"] = "инээмсэглэл, аз жаргалтай нүдтэ царай"//hugging face with smile and happy eyes
        enru2mn_re["думающее лицо"] = "бодож буй царай"//thinking face
        enru2mn_re["лицо с прижатым к губам пальцем"] = "уруулаа хуруугаахаа дарсан царай"//face with finger pressed to lips
        enru2mn_re["лицо без эмоций"] = "сэтгэл хөдлөлгүй царай"//face without emotion
        enru2mn_re["удивленное лицо с приподнятыми бровями"] = "хөмсөгөө өргөсөн гайхсан царай"//surprised face with raised eyebrows
        enru2mn_re["зевающее лицо с закрытыми глазами"] = "нүдээ аниад ившээж буй царай"//yawning face with closed eyes
        enru2mn_re["удивленное лицо с открытым ртом"] = "амаа нээгээд гайхсан царай"//surprised face with open mouth
        enru2mn_re["лицо человека, которого тошнит"] = "өвдсөн царай"//the face of a man who is sick
        enru2mn_re["поднятый большой палец"] = "дээшээ харсан эрхий хуруу"//raised thumb
        enru2mn_re["опущенный большой палец"] = "доошоо харсан эрхий хуруу"//drooping thumb
        enru2mn_re["кулак в правую сторону"] = "баруун тийшээ харсан нудрага"//fist to the right
        enru2mn_re["показывающая жест хеви-метала"] = "рок гарын дохио"//showing heavy metal gesture
        enru2mn_re["рука с жестом «ОК»"] = "ок гэсэн гарын дохио"//hand with OK gesture
        enru2mn_re["рука со скрещенными указательным и большим пальцами"] = "долоовор хуруугаараа дунд хуруугаа дарж буй дохио"
        enru2mn_re["жест «я люблю тебя»"] = "би чамд хайртай дохио"//i love you gesture
        enru2mn_re["поднятый кулак"] = "өргөсөн нудрага"//raised fist
        enru2mn_re["сжатый кулак"] = "зангидсан нударга"//clenched fist
        enru2mn_re["кулак в левую сторону"] = "зүүн тийш харсан нудрага"//fist to the left
        enru2mn_re["рукопожатие"] = "даллаж буй"//handshake
        enru2mn_re["аплодирующие руки"] = "баярлаж буй гарын дохио"//cheering hands
        enru2mn_re["поднятая рука с растопыренными пальцами"] = "гараа сунгаж буй"//raised hand with outstretched fingers
        enru2mn_re["тыльная сторона руки с выставленным средним пальцем"] = "дунд хуруугаа гаргаж буй"//the back of the hand with the middle finger extended
        enru2mn_re["сложенные вместе ладони"] = "алгаа хавсарч буй"//palms clasped together
        enru2mn_re["рука"] = "гар"//arm
        enru2mn_re["пишущая ручкой"] = "үзгээр бичиж буй"//writing with a pen
        enru2mn_re["рот"] = "ам"//mouth
        enru2mn_re["пожилая женщина"] = "өндөр настай эмэгтэй"//elderly woman
        enru2mn_re["пожилой мужчина"] = "өндөр настай эрэгтэй" //old man
        enru2mn_re["женщина-полицейский"] = "эмэгтэй цагдаа" //policewoman
        enru2mn_re["женщина-гвардеец"] = "эмэгтэй хамгаалагч"//female guard
        enru2mn_re["семья из матери"] = "гэр бүл"//mother's family
        enru2mn_re["отца"] = "аав"//father
        enru2mn_re["дочери и сына"] = "охин ба хүү"  //daughter and son
        enru2mn_re["блузка"] = "цамц"//blouse
        enru2mn_re["лодка"] = "завь"//boat
        enru2mn_re["шапочка выпускника"] = "төгсөлтийн малгай"//graduation hat
        enru2mn_re["кошелек"] = "түрүүвч"//wallet
        enru2mn_re["багаж"] = "багаж"//baggage
        enru2mn_re["собачья мордочка"] = "нохой"  // dog muzzle
        enru2mn_re["кошачья мордочка"] = "муур" // cat muzzle
        enru2mn_re["мышиная мордочка"] = "хулгана" //mouse muzzle
        enru2mn_re["мордочка хомяка"] = "усан гахай" //hamster face
        enru2mn_re["кроличья мордочка"] = "туулай"//rabbit muzzle
        enru2mn_re["лисья мордочка"] = "үнэг"//fox muzzle
        enru2mn_re["голова медведя"] = "баавгай"//bear head
        enru2mn_re["мордочка панды"] = "панда"//panda muzzle
        enru2mn_re["морда белого медведя"] = "цагаан байвгай"//muzzle of a polar bear
        enru2mn_re["мордочка коалы"] = "коала"//koala face
        enru2mn_re["пятачок"] = "гахай"//piglet
        enru2mn_re["поросячья морда"] = "гахайн хамар"//pig snout
        enru2mn_re["коровья морда"] = "үхэр"//cow muzzle
        enru2mn_re["львиная морда"] = "арслан"//lion muzzle
        enru2mn_re["тигриная морда"] = "бар"//tiger muzzle
        enru2mn_re["глобус с северной и южной америкой"] = "бөмбөрцөг"//globe with north and south america
        enru2mn_re["полная луна с лицом"] = "сар"//full moon with face
        enru2mn_re["знак высокого напряжения"] = "өндөр хүчдэлийн тэмдэг"//high voltage sign
        enru2mn_re["радуга"] = "солонго"//rainbow
        enru2mn_re["солнце"] = "нар"//sun
        enru2mn_re["солнце сквозь облака"] = "үүлэн дундах нар"//sun through the clouds
        enru2mn_re["облако"] = "үүл"//cloud
        enru2mn_re["огонь"] = "гал"//the fire
        enru2mn_re["взрыв"] = "дэлбэрэлт"//explosion
        enru2mn_re["зелёное яблоко"] = "ногоон алим"  //green apple
        enru2mn_re["красное яблоко"] = "улаан алим" //red apple
        enru2mn_re["груша"] = "лийр"//pear
        enru2mn_re["мандарин"] = "жүрж"//mandarin
        enru2mn_re["арбуз"] = "тарвас"//watermelon
        enru2mn_re["виноград"] = "усан үзэм"//grape
        enru2mn_re["клубника"] = "гүзээлзгэнэ"//Strawberry
        enru2mn_re["черника"] = "нэрс"//blueberry
        enru2mn_re["дыня"] = "тарвас"//melon
        enru2mn_re["вишенки"] = "интоор"//cherries
        enru2mn_re["персик"] = "тоор"//peach
        enru2mn_re["половинка кокоса"] = "дал модны жимс"//half a coconut
        enru2mn_re["фрукт киви"] = "киви жимс"//kiwi fruit
        enru2mn_re["баклажан"] = "хаш"//eggplant
        enru2mn_re["пачка масла"] = "цөцгийн тос"//pack of butter
        enru2mn_re["мясо на косточке"] = "ястай мах"//meat on the bone
        enru2mn_re["гамбургер"] = "гамбүргэр"//hamburger
        enru2mn_re["лепешка с начинкой"] = "бялуу"//stuffed cake
        enru2mn_re["попкорн"] = "попкорн"//popcorn
        enru2mn_re["именинный торт"] = "төрсөн өдрийн бялуу"//birthday cake
        enru2mn_re["чокающиеся пивные кружки"] = "шар айрагны аяга тулгаж буй"//clinking beer mugs
        enru2mn_re["чокающиеся бокалы шампанского"] = "дарс тулгаж буй"//clinking glasses of champagne
        enru2mn_re["футбольный мяч"] = "хөл бөмбөг"//soccer ball
        enru2mn_re["баскетбольный мяч"] = "сагсан бөмбөг"//basketball
        enru2mn_re["волейбол"] = "волейбол"//volleyball
        enru2mn_re["ракетка и шарик для настольного тенниса"] = "тэннис"//racket and table tennis ball
        enru2mn_re["бильярдный шар"] = "бильярдын бөмбөг"//billiard ball
        enru2mn_re["конек для катания на льду"] = "цасны тэшүүр"//ice skate
        enru2mn_re["кубок"] = "цом"//cup
        enru2mn_re["спортивная медаль"] = "медаль"//sports medal
        enru2mn_re["автомобиль"] = "машин"//car
        enru2mn_re["внедорожник"] = "бартааны машин"//SUV
        enru2mn_re["встречный поезд"] = "галт тэрэг"//oncoming train
        enru2mn_re["скоростной поезд с закругленной носовой частью"] = "хурдны галт тэрэг"//high-speed train with a rounded nose
        enru2mn_re["вертикальный светофор"] = "босоо гэрлэн дохио"//vertical traffic light
        enru2mn_re["горизонтальный светофор"] = "хэвтээ гэрлэн дохио"//horizontal traffic light
        enru2mn_re["открытка с фейерверком"] = "салют буудуулах карт"//fireworks card
        enru2mn_re["открытка с восходом солнца"] = "нар мандаж буй карт"//postcard with sunrise
        enru2mn_re["открытка с закатом солнца над зданиями"] = "барилга дээр нар жаргаж буй карт"//postcard with sunset over buildings
        enru2mn_re["открытка с изображением моста ночью"] = "шөнийн гүүрний карт"//bridge postcard at night
        enru2mn_re["часы"] = "цаг" //"clock"
        enru2mn_re["настольный компьютер"] = "Суурин компьютер"//desktop computer
        enru2mn_re["красное сердце"] = "улаан зүрх" //Red heart"
        enru2mn_re["красное забинтованное сердце"] = "улаан боолттой зүрх" //"red bandaged heart"
        enru2mn_re["красное сердце в виде восклицательного знака"] = "анхаарлын тэмдэгтэй зүрх" //"red heart exclamation mark"
        enru2mn_re["сердце со звездочками"] = "одтой зүрх" //"heart with stars"
        enru2mn_re["два сердца в кольце "] = "цагирган дотор хоёр зүрх" //"two hearts in a ring"
        enru2mn_re["синее сердце"] = "цэнхэр зүрх" //"blue heart"
        enru2mn_re["флаг Монголии"] = "монгол далбай" //"flag of mongolia"
        enru2mn_re["галочка"] = "чээк маарк" //"check mark"
        enru2mn_re["картинка с изображением национального парка"] = "үндэсний цэцэрлэгт хүрээлэнгийн зураг" //"national park picture"
        enru2mn_re["подарок"] = "бэлэг" //"gift"
        enru2mn_re["грузовик"] = "ачааны машин" //"truck"
    }
    
    func normalize(text: String) -> String {
        var text = text.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
        text = re.sub("([0-9]+)( из )([0-9]+)", "$1-с $3", text)
        if self.enru2mn[text] != nil {
            text = self.enru2mn[text]!
        }
        
        for (key, value) in self.enru2mn_re {
            // replace only words nothing else!
            text = text.replacingOccurrences(of: "\\b\(key)\\b", with: value, options: .regularExpression, range: nil)
        }
        
        NSLog("chimegesynth \(text)")
        return text
    }
}

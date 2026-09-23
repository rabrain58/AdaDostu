# AdaDostu — ilk cihaz denemesi

iPhone'un Dinamik Ada'sında kişisel kullanım için küçük bir piksel kedi.
SwiftUI uygulaması + ActivityKit/WidgetKit uzantısı. Abonelik, sunucu ve analiz takibi yok.

## İlk sürüm

- Mırmır adlı özgün piksel kedi, Bal / Bulut / Nane renkleri.
- Adaya gönder / Adadan al.
- Kompakt, minimal, genişletilmiş ada ve kilit ekranı görünümleri.
- Deneysel saniyelik hareket; sabit görünüm seçeneği.
- Hareketi Azalt veya Always-On kararması algılanırsa sabit kedi.

**Durum:** GitHub Actions üzerinde iPhone ARM64 derlemesi ve uygulama/uzantı paket kontrolleri geçti.
İmzasız IPA üretildi: [başarılı derleme ve indirme](https://github.com/rabrain58/AdaDostu/actions/runs/35935603814).
Derleme ortamı Xcode 16.4 / iOS 18.5 SDK; minimum hedef iOS 17.
Sideloadly kurulumu ve iPhone 14 Pro Max / kullanıcının bildirdiği iOS 27 üzerinde görünüm ile hareket **DOĞRULANMADI**.
Kaynak ZIP'i kurulabilir IPA değildir.

## IPA üretimi

1. Bu dosyaları yeni GitHub deponun köküne yükle; gizli `.github` klasörü dahil olmalı.
2. `main` dalına gönderildiğinde **Actions → Build iPhone IPA** çalışır.
   Gerekirse **Run workflow** ile başlat.
3. Yeşil tamamlanan çalıştırmada **Artifacts → AdaDostu-IPA** dosyasını indir.
4. ZIP'i aç. İçindeki `AdaDostu-unsigned.ipa` Sideloadly içindir.
5. Sideloadly'de uygulama uzantılarını koru; **Remove App Extensions / PlugIns**
   seçeneği varsa kapalı olmalı. Ada görünümü uzantı içinde.
6. IPA'yı kendi Apple hesabınla imzalayıp yükle. GitHub'a Apple şifresi veya sertifika yükleme.
7. AdaDostu'yu aç, **Adaya gönder** düğmesine bas ve ana ekrana dön.

Ücretsiz Apple hesabında yeniden imzalama süresi ve uygulama/kimlik kotası geçerlidir.
Sideloadly'nin ana uygulamayla uzantıyı birlikte imzalaması gerekir.
GitHub özel depolarında macOS derlemeleri hesabın Actions kotasını kullanır.

## Hareket nasıl deneniyor?

Standart Live Activity animasyonları sürekli bir oyun döngüsü değildir.
Bu prototipte iOS'un güncellediği `Text(timerInterval:...)` kullanılır.
Özgün `AdaCat.ttf` yazı tipindeki 0–9 karakterleri farklı kedi pozlarıdır;
yalnızca saniyenin son hanesi görünür. Böylece yaklaşık saniyelik kare değişimi
denenir. Arka planda ses, konum takibi, sonsuz görev veya bildirim sunucusu kullanılmaz.

Bu birleşim Apple'ın garanti ettiği bir animasyon API'si değildir.
iOS sürümüne, WidgetKit metin yerleşimine ve güç durumuna göre donabilir,
sayı gösterebilir veya farklı hizalanabilir. Font yüklenemezse sabit kedi kullanılır;
font yüklenip sistem çizim sırasında farklı davranırsa bunu otomatik tespit edemeyiz.
**Minik adımlar** kapatılarak sabit görünüm denenebilir.

Oturum en fazla 8 saat sürer; ardından uygulamadan yeniden başlatılır.
Müzik, arama ve başka Live Activity'ler ada görünümünü değiştirebilir.
Uygulama içindeki ada çizimi açıkça bir önizlemedir.

## Telefon kabul kontrolü

- Başlat: ana ekranda adada kedi görünmeli.
- Hareket: ekran açıkken en az 15 saniye gözle; sayı, kırpılma veya donma varsa kaydet.
- Adada uzun bas: geniş görünüm; adaya dokun: uygulama açılmalı.
- Ekranı kilitle: kilit ekranı görünümü kontrol edilmeli.
- Uygulamaya dön: mevcut oturum tanınmalı; tekrar başlatmada kopya oluşmamalı.
- Adadan al: ada ve kilit ekranı görünümü kalkmalı.
- Renk değiştirip yeniden başlat: yeni renk görünmeli.
- Minik adımlar kapalı: sabit, düzgün kedi görünmeli.
- Canlı Etkinlik izni kapalı: anlaşılır hata gösterilmeli.

## Geliştirme

Minimum hedef iOS 17'dir; daha yeni iOS'ta çalışabilmesi için yalnızca eski, mevcut API'ler kullanılır.
iOS 27 SDK'sına özel bir API gerekmez. Gerçek sürüm uyumluluğu cihaz testiyle belirlenecek.

Mac üzerinde Xcode ve XcodeGen ile:

```sh
xcodegen generate
xcodebuild -project AdaDostu.xcodeproj -scheme AdaDostu -configuration Release \
  -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath .derived \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build
python3 scripts/verify_bundle.py .derived/Build/Products/Release-iphoneos/AdaDostu.app
```

Piksel fontu / ikonlar depoda hazır. Yeniden üretmek için Python, Pillow ve fonttools gerekir:

```sh
python -m pip install --target .build-tools fonttools==4.61.1 Pillow==11.3.0 PyYAML==6.0.2
python scripts/generate_assets.py
python scripts/check_sources.py
```

`check_sources.py` varlık ve paket yapılandırmasını denetler; Swift derlemesi veya iPhone testi yerine geçmez.
`verify_bundle.py` GitHub'da gerçek derleme çıktısını kontrol eder.

## Kaynaklar

- [Apple: Live Activities](https://developer.apple.com/design/human-interface-guidelines/live-activities)
- [Apple: Timer text](https://developer.apple.com/documentation/swiftui/text/init(timerinterval:pausetime:countsdown:showshours:))
- [GitHub Actions macOS ortamları](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)
- [Sideloadly](https://sideloadly.io/)

Görseller ve AdaCat yazı tipi bu proje için üretilmiştir; iScreen varlığı içermez.

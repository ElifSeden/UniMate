# UniMate

UniMate, üniversite öğrencilerinin akademik ve kişisel verimliliğini artırmak için geliştirilmiş hepsi‐bir‐arada bir mobil uygulamadır. Ders planlamadan AI destekli özetleme, soru çözümünden ruh hali takibine kadar pek çok özelliği bir arada sunar.

---

## 🔑 API Anahtarı Gerekli

UniMate uygulaması Gemini API kullanmaktadır.  
API Key almak için: [https://makersuite.google.com/](https://makersuite.google.com/)

Uygulamayı çalıştırmadan önce projenizin kök dizinine bir `.env` dosyası ekleyip içine aşağıdakini yazın:

```env
GEMINI_API_KEY=YOUR_API_KEY_HERE
```

---

## Özellikler

### 📅 Haftalık Test & Çalışma Planlayıcı
- Haftaya ait sınav ve çalışma takviminizi görüntüleyin.
- Yaklaşan 3 sınavınızı ana ekranda hızlıca görün.
- Sınav ekleyin, düzenleyin, silin ve isterseniz hatırlatıcı bildirim atın.

### 📄 PDF Özetleyici
- PDF dosyalarını cihazdan seçin veya kamerayla tarayın.
- PDF içeriğini Gemini API ile analiz edip özet çıkarın.
- Özet metnini uygulama içinde görüntüleyin ve sesli dinleyin.

### ❓ Soru Çözüm Asistanı
- Öğrenci tarafından girilen veya fotoğrafla yüklenen sorulara adım adım çözümler sunar.
- Çözüme benzer sorular önerir.

### 📝 AI Destekli Quiz Oluşturucu
- PDF’ten Çoktan Seçmeli, Boşluk Doldurma (drag & drop) ve Açık Uçlu soru setleri oluşturun.
- Soru sayısı ve tipi seçimi.
- Yanlış cevaplarda açıklama ve PDF’den ilgili bölümü gösterme.

### 😊 MoodCheck – Ruh Hali & Motivasyon
- Günlük ruh halinizi emoji ile seçin.
- Günlük görevleri tamamladıkça rozet kazanın.
- Son 7 güne ait ruh hali grafiği ve takvim görünümü.
- AI’den motivasyon mesajı alın.
- Günlük bildirimle ruh hali takibi hatırlatması.

### ⏱ Zaman Yönetimi
- Uygulama içinde geçirdiğiniz süreyi takip edin.
- Belirlediğiniz kullanım limitine ulaştığınızda bildirim alın.

### 🕵️‍♂️ AI Tespit & Paraphrase Aracı
- Metin yapıştırarak AI tarafından oluşturulup oluşturulmadığını analiz edin.
- Girilen metni doğal, öğrenci dostu bir dille yeniden yazdırın.

### 🎓 AI Destekli CV Oluşturucu
- Kişisel bilgiler, eğitim, deneyim ve becerilerinizi girin.
- Profil fotoğrafı, tema rengi ve şablon seçin.
- Şık, iki sütunlu CV’nizi PDF olarak oluşturup indirin.
- ATS uyumlu; QR kod, ikonlu başlıklar, hizalanmış tarih & içerik düzeni.

### 🔐 Firebase Auth & Profil Yönetimi
- E-posta/şifre ile kullanıcı girişi ve kayıt.
- Firestore’da profil bilgilerinizi (isim, soyisim, doğum tarihi, okul vb.) saklama ve düzenleme.
- Her açılışta giriş kontrolü; üye olmayanları otomatik kayıt ekranına yönlendirme.

---

## Kurulum & Çalıştırma

1. Depoyu klonlayın  
   ```bash
   git clone https://github.com/yourusername/UniMate.git
   cd UniMate
   ```

2. `.env` dosyasını oluşturun ve `GEMINI_API_KEY` değerinizi ekleyin (bkz. “🔑 API Anahtarı Gerekli”).

3. Terminal’de Swift paketlerini güncelleyin  
   ```bash
   swift package resolve
   ```

4. `UniMate.xcodeproj` dosyasını Xcode ile açın ve çalıştırın.

---

## Teknolojiler

- **Swift & SwiftUI** – Tüm arayüz ve iş mantığı  
- **Gemini API** – AI tabanlı özetleme, soru üretme, metin işleme  
- **Firebase Auth & Firestore** – Kullanıcı yönetimi ve veri depolama  
- **PDFKit** – PDF okuma ve oluşturma  
- **AVFoundation** – Metin okuma (Text-to-Speech)  

---

## Katkıda Bulunma

1. Fork’layın (🔀)  
2. Yeni bir branch açın: `git checkout -b feature/özellik-adi`  
3. Değişikliklerinizi commitleyin: `git commit -m 'Yeni özellik ekle: ...'`  
4. Branch’e push edin: `git push origin feature/özellik-adi`  
5. Pull request açın  

---

## Lisans

MIT License © 2025 Elif Yurtseven  

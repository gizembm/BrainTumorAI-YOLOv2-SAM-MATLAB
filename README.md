# 🧠 YOLOv2 ve SAM ile Beyin Tümörü Tespiti ve Segmentasyonu

Bu proje, manyetik rezonans görüntülerinde (MRG) bulunan beyin tümörlerinin **otomatik olarak tespiti ve segmentasyonu** amacıyla geliştirilmiştir. MATLAB ortamında geliştirilen bu sistem, **YOLOv2** nesne tespiti algoritması ve **Segment Anything Model (SAM)** segmentasyon mimarisinin birlikte kullanıldığı iki aşamalı bir yapay zekâ çözümüdür. Ayrıca, son kullanıcıların sistemi rahatlıkla deneyimleyebilmesi için **grafiksel kullanıcı arayüzü (GUI)** de oluşturulmuştur.

---

## 🔍 Projenin Amacı

Beyin tümörlerinin manuel olarak analiz edilmesi zaman alıcı ve yoruma dayalıdır. Bu nedenle, bu projede amaçlanan:

- MRI görüntülerinde yer alan tümörlerin **otomatik olarak tespit edilmesi**
- Tespit edilen bölgelerin **piksel düzeyinde segmentasyonu**
- Tüm sürecin, son kullanıcı (ör. doktor, öğrenci) tarafından **arayüz üzerinden sezgisel şekilde kullanılabilmesi**

---

## 🛠️ Kullanılan Yöntemler

### 1. **YOLOv2 (You Only Look Once)**
- Hızlı ve tek-aşamalı nesne tespiti algoritmasıdır.
- Çalışmada, farklı *backbone* mimarileri ile eğitildi:
  - `SqueezeNet`: Hafif ve hızlı
  - `MobileNet-v2`: Düşük parametreli, dengeli
  - `ResNet-50`: Derin yapı, yüksek doğruluk potansiyeli

### 2. **Segment Anything Model (SAM)**
- Meta AI tarafından geliştirilen, prompt-temelli genel amaçlı segmentasyon modelidir.
- Tespit kutuları giriş olarak verilerek, tümör bölgeleri **piksel düzeyinde maskeleme** ile çıkarılmıştır.

### 3. **MATLAB GUI**
- Model seçimi (YOLOv2 veya SAM)
- Görüntü yükleme
- Tahmin ve segmentasyon çıktıları ile kullanıcı bilgilendirmesi
- Anlaşılır arayüz, tek tıklamayla işlem

---

## 🧠 Kullanılan Veri Seti

- Toplam **243 adet MRI görüntüsü** içerir.
  - 155 adet tümörlü görüntü (`tumor` klasörü)
  - 88 adet tümörsüz görüntü (`no` klasörü)
- Görüntüler `227×227×3` boyutuna yeniden ölçeklendirildi.
- Tümörlü görüntüler, MATLAB `Image Labeler` aracı ile **manuel olarak etiketlendi**.
- Etiketler, `YOLOv2_dataset.mat` dosyası içinde saklanmaktadır.

---

## 🏗️ Model Eğitimi ve Hiperparametreler

| Parametre                  | Değerler                           |
|---------------------------|------------------------------------|
| Eğitim/Doğrulama/Test     | %70 / %15 / %15                   |
| Epoch sayısı              | 30                                 |
| Batch boyutu              | 16                                 |
| Öğrenme oranı             | 0.001 ve 0.0001                    |
| Optimizasyon algoritması  | Adam / SGDM                        |
| Anchor kutu sayısı        | 5 (otomatik tahmin edildi)         |
| Aktivasyon (çıktı katmanı)| Sigmoid                            |
| Donanım                   | CPU (MATLAB ortamında)             |
| Veri artırma (augmentation)| Dönme, çevirme, parlaklık, kontrast |

---

## 📊 Performans Sonuçları

YOLOv2 modeli farklı mimarilerle test edilmiştir. Aşağıdaki tablo, segmentasyon öncesi tespit başarılarını özetler:

| Model               | mAP   | Recall | Precision | F1 Score |
|---------------------|-------|--------|-----------|----------|
| SqueezeNet (High)   | 0.711 | 0.782  | 0.642     | 0.705    |
| MobileNet (Low)     | 0.644 | 0.739  | 0.809     | 0.772    |
| ResNet-50 (High)    | **0.958** | **0.958** | **1.000** | **0.978** |

> Not: ResNet-50 ile yüksek doğruluk elde edilmiştir ancak sınırlı veri nedeniyle "overfitting" riski göz önünde bulundurulmalıdır. MobileNet daha kararlı ve genellenebilir sonuçlar sunmuştur.

---

## 🖥️ Grafiksel Kullanıcı Arayüzü (GUI) Özellikleri

GUI, tüm süreci sezgisel olarak yönetebileceğiniz bir arayüz sunar:

- 🔄 **Model Seçimi**: YOLOv2 veya SAM
- 📂 **Görüntü Yükleme**: .jpg uzantılı MRI görüntüleri
- 🎯 **Tahmin**: 
  - Tümör tespit kutusu (kırmızı çerçeve)
  - Segmentasyon maskesi (kırmızıya dönük maske)
- 📝 **Bilgilendirme Mesajları**:
  - Örnek: “Tümör %84.84 olasılıkla tespit edildi.”
  - “Tümör segmentasyonu gösterildi (SAM).”
  - “Tümör tespit edilmedi.”

---

### 🔧 Arayüzden Görüntüler

#### Ana Arayüz
![image](https://github.com/user-attachments/assets/e2909517-86e4-4edc-85bf-c89af679d0d3)

#### Görüntü Yüklendiğinde
![image](https://github.com/user-attachments/assets/ed0ff53c-7027-4925-b131-ed6d4a8a6181)

#### YOLOv2 Tespit Sonucu
![image](https://github.com/user-attachments/assets/4ef70daf-93a1-442a-a407-2f63b762662e)

#### SAM ile Segmentasyon
![image](https://github.com/user-attachments/assets/ba815799-e4ef-4fc7-b1b1-752efecd270a)

#### Tümör Tespit Edilemedi
![image](https://github.com/user-attachments/assets/01a9a200-14f8-409c-91b9-5c5166f9d687)

---

## 📚 Referanslar

Proje kapsamında yararlanılan başlıca çalışmalar:

- Kumar & Jain (2021) - YOLOv2 ile beyin tümörü tespiti
- Li et al. (2022) - Mobil cihazlar için hafif YOLOv2 mimarileri
- Zhang & Chen (2023) - SAM ile MRG segmentasyonu
- Das & Noor (2024) - YOLOv2 + SAM entegrasyonu
- El-Baz et al. (2022) - Gerçek zamanlı GUI sistemleri


---


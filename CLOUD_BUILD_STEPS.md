# Cloud se APK Banane ke Steps (bina Flutter install kiye)

Ye poora kaam GitHub ke free servers par hota hai. Tumhare computer par sirf
browser chahiye — kuch install nahi karna.

## Step 0 — Pehle apna domain daalo
Is folder ke andar `lib/config.dart` file kholo aur ye line badlo:

```dart
static const String baseUrl = 'https://YOUR-DOMAIN.com/foodapp';
```

Apni actual cPanel website ke domain se replace karo (jaha `foodapp/` folder
upload kiya hai). Agar website root me hai (subfolder nahi) to `/foodapp`
hata dena.

## Step 1 — GitHub account banao
https://github.com par free account banao (agar pehle se nahi hai).

## Step 2 — Naya repository banao
- GitHub par "New repository" par click karo.
- Naam do (jaise `foodiehub-app`), **Private** select kar sakte ho.
- "Create repository" dabao.

## Step 3 — Is poore folder ko upload karo
Repo page par "uploading an existing file" link milega (ya "Add file" ->
"Upload files"). Is `foodapp_flutter` folder ke andar ka **saara content**
(pubspec.yaml, lib/, .github/ sab kuch, folder ke andar se) drag-drop karke
upload kar do, phir "Commit changes" dabao.

⚠️ Zaroori: folder ke andar se files upload karo, poora folder zip karke mat
daalna — GitHub ko `pubspec.yaml` root me chahiye.

## Step 4 — Build apne aap shuru ho jayega
Upload hote hi upar "Actions" tab me ek build automatically shuru ho jayega
(iska naam "Build Android APK" hoga). Isme 5-8 minute lagte hain. Green tick
✅ ka wait karo.

## Step 5 — APK download karo
Jab build complete ho jaye (✅ green), us build par click karo. Neeche
"Artifacts" section me `foodiehub-release-apk` milega — uspar click karke
zip download karo. Andar `app-release.apk` hoga — yehi tumhara mobile app hai.

## Step 6 — Phone par install karo
APK ko phone me bhejo (WhatsApp/Drive/USB), phone settings me "install from
unknown sources" allow karo, phir APK par tap karke install karo.

## Test zaroor karna
Register, login, food browse, cart, checkout karke dekho ki order tumhare
cPanel admin panel me sahi se aa raha hai.

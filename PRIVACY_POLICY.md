# Privacy Policy - ARUT

Last Updated: October 4, 2026


### 0. Rule 0: Disclaimer on Modified Builds, External APKs, Host Software, Executables & Unofficial Forks:

- **Original Source Integrity:** This privacy policy, safety guarantees, and security features apply strictly and exclusively to the official, unmodified source code and binaries — including the **Android client APK**, **Host Relay Servers (Rust / Java)**, **launcher scripts (`arut`, `arut.cmd`, `arut-run.cmd`)**, and **executable binaries for Windows, Linux, and macOS** — distributed directly through this official repository ([hamzabellouch/arut](https://github.com/hamzabellouch/arut)) and its verified official releases.
- **Zero Liability for Modified / External Software & Builds:** We (the publisher and maintainer) assume **no responsibility or liability whatsoever** for any modified APKs, unofficial software, third-party forks, repackaged desktop binaries (Executables, JARs), custom launcher scripts, or altered software not originating directly from this official repository. Any installation, execution, or use of modified, tampered, or third-party builds/software is entirely at your own risk, and the publisher assumes no responsibility for any consequences, damages, security compromises, or data breaches that may occur.


### 1. Executive Summary & Overview:

ARUT is an open-source tool and Android client application designed for seamless, rootless reverse tethering over USB via `adb`, allowing connected Android devices to access the internet connection of the host computer.

#### Core Privacy Commitment:
ARUT operates "100% locally on-device and over direct local USB tunnels". We do not collect, store, transmit, share, or sell any personal data, usage logs, device identifiers, network payloads, or browsed URLs to external analytics servers or third parties.


### 2. Information Processed On-Device:
To perform reverse tethering and network forwarding, ARUT processes the following data `locally on your device`:

- **Local Packet Buffers:** Processed in real-time within volatile memory (RAM) strictly to route Level 3 (IPv4) packets through the local reverse ADB tunnel to the host relay server. Packet contents are never saved, recorded, stored to disk, or inspected.
- **Connection Identifiers:** Ephemeral 5-tuple metadata (source IP, destination IP, source port, destination port, protocol) maintained temporarily in memory to multiplex active TCP and UDP streams.
- **DNS Configurations:** User-specified custom DNS server addresses (if provided via launcher options) are held in volatile memory solely during the active reverse tethering session.


### 3. Permissions Used & Their Purposes:
ARUT requests specific Android permissions strictly to deliver its core network forwarding functionality:

**A. VPN Service Binding** (`android.permission.BIND_VPN_SERVICE`)
- **Purpose:** Enables ARUT to establish a local virtual network interface (`VpnService`) on the Android device to intercept outbound IPv4 packets and forward them over USB.
- **Scope:** Used strictly while reverse tethering is active.

**B. Foreground Service** (`FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_CONNECTED_DEVICE`, `FOREGROUND_SERVICE_SPECIAL_USE`)
- **Purpose:** Keeps the reverse tethering network tunnel alive reliably in the background without Android OS process termination during active USB connections.
- **Scope:** Active only when a tethering session is initiated by the user.

**C. Internet & Network State** (`INTERNET` & `ACCESS_NETWORK_STATE`)
- **Purpose:** Allows the Android client to establish loopback socket connections with the local relay server over the ADB reverse redirected port (`localhost:26074`) and check network state.
- **Scope:** Used strictly for local loopback socket tunneling. No telemetry or external server communication occurs.

**D. Post Notifications** (`POST_NOTIFICATIONS`)
- **Purpose:** Displays the required foreground service status notification on Android 13+ while reverse tethering is active.
- **Scope:** Used strictly for system status alerts.


### 4. Network Tunneling & Routing Safety Policy:
ARUT complies fully with privacy and network safety principles:

- **Strict Local Isolation:** All network packets are transmitted exclusively through a direct, wired USB cable connection via `adb reverse`. Traffic never routes through third-party servers or remote proxies.
- **Zero Deep Packet Inspection (DPI):** ARUT functions as a stateless Level 3 to Level 5 transport relay. It does not terminate SSL/TLS encryption, alter packet payloads, or inspect unencrypted data.
- **Explicit User Consent & System Control:** Android's native `VpnService` permission dialog requires explicit user confirmation before any network traffic is routed through ARUT.


### 5. Data Sharing, Analytics & Advertising:

- **No Data Sharing:** No personal user data, network traffic, or hardware identifiers leave your local device and host computer.
- **No Third-Party Analytics / Tracking:** ARUT contains no analytics SDKs, telemetry beacons, or crash-reporting trackers.
- **No Ads:** ARUT is 100% free, open-source, and contains no advertisements.


### 6. Data Retention & Lifecycle:

- **Volatile Buffer Wiping:** All network buffers held during routing are discarded from volatile memory (RAM) immediately upon packet delivery or socket closure.
- **No Persistent Storage:** ARUT does not write network payloads, traffic logs, or visited hostnames to persistent disk storage.


### 7. Managing Permissions & User Rights:
You maintain full control over ARUT on your device:

**A. Disconnect / Revoke VPN:** Stop the session via CLI (`arut stop`) or navigate to: `Settings > Network & internet > VPN > ARUT > Disconnect / Forget VPN`.

**B. Disable Notifications:** `Settings > Apps > ARUT > Notifications > Turn Off`.


### 8. Contact & Support:
If you have any questions or feedback regarding this Privacy Policy or ARUT, please contact us at:  
Email: hamzabellouchcontact@gmail.com


-------------------------------------------



# سياسة الخصوصية - ARUT
آخر تحديث: ٤ أكتوبر ٢٠٢٦

### ٠. القاعدة رقم ٠: إخلاء المسؤولية عن التطبيق والبرمجيات والنسخ المعدلة وحزم APK والملفات التنفيذية والمشاريع المشتقة:

* **سلامة المصدر الأصلي:** تنطبق سياسة الخصوصية، وضمانات الأمان، ومعايير الحماية المذكورة في هذه الوثيقة حصرياً وصراحةً على الشفرة المصدرية والإصدارات الرسمية غير المعدلة — سواء **تطبيق Android (بصيغة APK)**، أو **برمجيات خوادم الترحيل (Relay Servers)**، أو **الملفات التنفيذية والسكربتات لأنظمة Windows و Linux و macOS (مثل ملفات `.exe` و `.jar` و `.cmd` والسكربتات التنفيذية)** — المنشورة مباشرة عبر هذا المستودع الأصلي المعتمد ([hamzabellouch/arut](https://github.com/hamzabellouch/arut)) وقسم الإصدارات الرسمية التابع له فقط.
* **عدم تحمل المسؤولية عن البرمجيات والنسخ المعدلة أو الخارجية:** نحن (الناشر والمطور) **لا نتحمل أي مسؤولية قانونية أو أمنية أو تقنية** عن تثبيت أو تشغيل أو استخدام أي تطبيقات أو برمجيات معدلة، أو حزم APK خارجية، أو ملفات تنفيذية ومكتبات (Binaries / Executables / JARs) مُعاد تجميعها، أو سكربتات تشغيل غير رسمية، أو مشاريع مشتقة لا تنتمي مباشرة لهذا المستودع الأصلي. إن أي تثبيت أو تشغيل لبرمجيات أو نسخ خارجية أو معدلة يقع بالكامل على مسؤولية ومخاطرة المستخدم وحده دون أدنى مسؤولية على الناشر عن أي أضرار أو ثغرات أمنية أو فقدان للبيانات قد ينتج عن ذلك.


### ١. الملخص التنفيذي والنظرة العامة:

تطبيق وأداة ARUT هو مشروع مفتوح المصدر مصمم لمشاركة اتصال الإنترنت من جهاز الكمبيوتر إلى هاتف Android عبر كابل USB وبدون روت (Reverse Tethering) بالاعتماد على أداة `adb`.

#### الالتزام الأساسي بالخصوصية:
يعمل ARUT بنسبة "١٠٠٪ محلياً على الجهاز وعبر كابل USB المباشر". نحن لا نجمع أو نخزن أو ننقل أو نشارك أو نبيع أي بيانات شخصية أو سجلات استخدام أو معرّفات الجهاز أو حزم البيانات أو عناوين المواقع إلى خوادم تحليلات خارجية أو أطراف ثالثة.


### ٢. المعلومات التي تتم معالجتها على الجهاز:
لتنفيذ التوصيل العكسي للإنترنت وإعادة توجيه الحزم، يقوم ARUT بمعالجة البيانات التالية "محليًا على جهازك":

* **حزم البيانات المؤقتة (Packet Buffers):** تتم معالجتها في الوقت الفعلي داخل الذاكرة العشوائية المؤقتة (RAM) فقط لتوجيه حزم IPv4 عبر نفق ADB المحلي إلى خادم الترحيل (Relay Server) على الكمبيوتر. لا يتم حفظ محتويات الحزم أو تسجيلها أو تخزينها على القرص مطلقًا.
* **معرّفات الاتصال (Connection Identifiers):** بيانات وصفية مؤقتة (عنوان IP المصدر والوجهة، والمنافذ، ونوع البروتوكول) تُحفظ مؤقتًا في الذاكرة لتنظيم مسارات TCP و UDP النشطة.
* **إعدادات خوادم DNS:** في حال تحديد خوادم DNS مخصصة من قِبل المستخدم، يتم الاحتفاظ بها في الذاكرة المؤقتة فقط خلال جلسة التوصيل النشطة.


### ٣. الأذونات المستخدمة وأغراضها:
يطلب ARUT أذونات Android محددة فقط لتقديم وظائف توجيه الشبكة الأساسية:

**أ. إذن خدمة الشبكة الافتراضية (`android.permission.BIND_VPN_SERVICE`)**
* **الغرض:** يمكّن ARUT من إنشاء واجهة شبكة افتراضية محلية (`VpnService`) على جهاز Android لاعتراض حزم IPv4 الصادرة وإعادة توجيهها عبر USB.
* **النطاق:** يُستخدم حصريًا أثناء تشغيل التوصيل العكسي للإنترنت.

**ب. إذن الخدمة في الواجهة الأمامية (`FOREGROUND_SERVICE` & `CONNECTED_DEVICE`)**
* **الغرض:** يحافظ على استمرارية نفق الشبكة في الخلفية دون أن يقوم نظام Android بإيقافه أثناء اتصال كابل USB.
* **النطاق:** ينشط فقط عند بدء جلسة التوصيل بواسطة المستخدم.

**ج. إذن الإنترنت وحالة الشبكة (`INTERNET` & `ACCESS_NETWORK_STATE`)**
* **الغرض:** يسمح لتطبيق Android بالتواصل محليًا مع خادم الترحيل عبر المنفذ المعاد توجيهه (`localhost:26074`) ومراقبة حالة الاتصال.
* **النطاق:** يُستخدم حصريًا للاتصال المحلي (Loopback Socket). لا يتم إجراء أي اتصال بخوادم خارجية.

**د. إذن إرسال الإشعارات (`POST_NOTIFICATIONS`)**
* **الغرض:** يعرض إشعار الخدمة النشطة وتنبيهات الحالة المطلوبة من نظام Android 13 فما فوق.
* **النطاق:** يُستخدم حصريًا لإشعارات حالة النظام.


### ٤. سياسة أمان نفق الشبكة وإعادة التوجيه:
يلتزم ARUT التزامًا كاملًا بمعايير الأمان والخصوصية:

* **عزل محلي كامل عبر USB:** يتم نقل جميع الحزم حصريًا عبر كابل USB المباشر باستخدام `adb reverse`. لا تمر حركة المرور عبر خوادم وسيطة أو سحابية.
* **عدم فحص أو تعديل محتوى الحزم (No DPI):** يعمل ARUT كوسيط نقل بين الطبقة الثالثة والخامسة (Level 3 to Level 5). ولا يقوم بفك تشفير اتصالات SSL/TLS أو تعديل محتوى الحزم أو فحص البيانات المشفرة.
* **موافقة صريحة للمستخدم:** تطلب نافذة إذن VPN الأصلية في نظام Android موافقة واضحة من المستخدم قبل بدء توجيه أي بيانات.


### ٥. مشاركة البيانات والتحليلات والإعلانات:

* **عدم مشاركة البيانات:** لا تغادر أي بيانات شخصية أو حزم بيانات جهازك أو كمبيوترك المحلي.
* **عدم وجود تحليلات أو تتبع:** لا يحتوي ARUT على أي حزم برمجية للتحليلات (Analytics SDKs) أو التتبع أو جمع الأخطاء عن بُعد (Telemetry).
* **لا توجد إعلانات:** تطبيق ARUT مجاني ومفتوح المصدر وخالٍ تماماً من الإعلانات.


### ٦. الاحتفاظ بالبيانات ودورة حياتها:

* **مسح الذاكرة المؤقتة فوراً:** يتم التخلص من جميع حزم البيانات المخزنة في الذاكرة العشوائية (RAM) فور تسليمها أو إغلاق المقبس (Socket).
* **لا يوجد تخزين دائم:** لا يكتب ARUT أي سجلات تصفح أو محتويات حزم على قرص التخزين الدائم.


### ٧. إدارة الأذونات وحقوق المستخدم:
تحتفظ بالتحكم الكامل في تطبيق ARUT على جهازك:

**أ. إيقاف أو إلغاء إذن الـ VPN:** يمكنك إيقاف الجلسة عبر الأمر (`arut stop`) أو من إعدادات Android: `الإعدادات > الشبكة والإنترنت > VPN > ARUT > قطع الاتصال / حذف ملف تعريف VPN`.

**ب. تعطيل الإشعارات:** `الإعدادات > التطبيقات > ARUT > الإشعارات > إيقاف التشغيل`.


### ٨. التواصل والدعم:
إذا كانت لديك أي أسئلة أو استفسارات بشأن سياسة الخصوصية هذه، يُرجى التواصل معنا عبر:  
البريد الإلكتروني: hamzabellouchcontact@gmail.com

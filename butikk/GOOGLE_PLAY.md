# Karos Habits – Google Play

Alt du trenger å lime inn i Play Console, samlet på ett sted.
Grafikk ligger i `butikk/play/`.

---

## Grunninfo

| Felt | Verdi |
| --- | --- |
| Navn | **Karos Habits** |
| Pakkenavn | `com.bullpeak.karoshabits` |
| Versjon | 1.0.2 (versionCode 13) |
| Kategori | Produktivitet (alternativ: Helse og trening) |
| Språk | **English (United States)** som standard + **Norsk** – appen følger telefonens språk |
| Pris | Gratis. Kjøp i appen: ja (frivillig TipJar). Ingen reklame |
| Personvern-URL | https://teambullpeak.com/karos-habits/privacy |
| Nettsted | https://teambullpeak.com/ |
| Kontakt-e-post | post@teambullpeak.com |

---

## Store listing (English)

**App name (max 30)**
> Karos Habits

**Short description (max 80)** – 69 tegn
> Track daily habits, build streaks and see your progress week by week.

**Full description (max 4000)**
> Karos Habits is a simple, friendly habit tracker. Add the habits you care about, check them off each day, and watch your streaks grow.
>
> **Two kinds of habits**
> • Yes/no habits – "Read 20 minutes", "Stretch", "No phone after 22:00"
> • Count habits with a daily goal – "Drink 8 glasses of water", "Walk 10,000 steps"
>
> **See your progress**
> • Today view with a clear progress bar
> • Weekly overview and your best habits
> • Month and year view for every habit
> • Streaks that keep you motivated
>
> **Private by design**
> No account, no login, no ads, no tracking. Your data stays on your phone. Export a backup file whenever you like, and import it on a new phone.
>
> Available in English and Norwegian.
>
> Made by Team BullPeak, starring Karo.

**Grafikk**

| Felt | Fil |
| --- | --- |
| App-ikon 512×512 | `play/icon_512.png` |
| Feature graphic 1024×500 | `play/feature_graphic_1024x500.png` |
| Telefon-skjermbilder (2–8) | `play/skjerm_1…4_1080x1920.png` |

**KI-merking:** Ikonet, Karo-figuren og tegneseriene er laget med KI (ChatGPT). Når Play Console spør om KI-generert innhold, svarer du **Ja**.

Nettbrett-skjermbilder er valgfritt. De trengs bare hvis du vil at appen skal fremheves for nettbrett.

---

## Butikktekster (norsk – ekstra språk)

Legg til under *Hovedoppføring i butikken → Administrer oversettelser → Norsk*.

**Appnavn (maks 30)**
> Karos Habits

**Kort beskrivelse (maks 80)** – 68 tegn
> Følg vanene dine hver dag, bygg rekker og se fremgangen uke for uke.

**Full beskrivelse (maks 4000)**
> Karos Habits er en enkel og vennlig vanesporer. Legg til vanene som betyr noe for deg, kryss dem av hver dag og se rekkene vokse.
>
> **To typer vaner**
> • Ja/nei-vaner – «Lese 20 minutter», «Tøye ut», «Ingen mobil etter 22»
> • Tellevaner med dagsmål – «Drikke 8 glass vann», «Gå 10 000 skritt»
>
> **Se fremgangen din**
> • I dag-visning med tydelig fremdriftslinje
> • Ukeoversikt og dine beste vaner
> • Måneds- og årsvisning for hver vane
> • Rekker som holder motivasjonen oppe
>
> **Personvern først**
> Ingen konto, ingen innlogging, ingen reklame, ingen sporing. Dataene blir på telefonen din. Eksporter en sikkerhetskopi når du vil, og importer den på en ny telefon.
>
> Finnes på norsk og engelsk.
>
> Laget av Team BullPeak, med Karo i hovedrollen.

Skjermbildene er på engelsk og brukes for begge språk.

---

## Appinnhold (App content)

### Personvernerklæring
Lim inn: `https://teambullpeak.com/karos-habits/privacy`

> **Forslag til endring på nettsiden:** Under «Third-party services» står det «None». Siden TipJar finnes, bør det stå noe slikt som:
> *"Optional tips are processed by Google Play and the Apple App Store. We do not receive or store your payment details."*

### Annonser
**Nei**, appen inneholder ikke annonser.

### Apptilgang
**Alle funksjoner er tilgjengelige uten spesiell tilgang** (ingen innlogging).

### Datasikkerhet (Data safety)
- Samler appen inn eller deler noen av de påkrevde brukerdatatypene? **Nei**
  - Vanedata lagres bare lokalt på telefonen.
  - Eksport av backup skjer bare når brukeren selv velger det, og fila går dit brukeren deler den. Det regnes ikke som innsamling.
  - Kjøp i TipJar håndteres av Google Play Billing. Appen sender ingen data til egne servere.
- Sletting av data: ikke aktuelt, siden det ikke finnes noen konto. Data slettes når appen avinstalleres.

### Innholdsvurdering (IARC)
- Kategori: **Alle andre apptyper** (verktøy/produktivitet, ikke spill)
- Vold, seksuelt innhold, banning, rusmidler, gambling: **Nei** på alt
- Samhandling mellom brukere / deling av innhold: **Nei**
- Deler posisjon: **Nei**
- Digitale kjøp: **Ja** (TipJar)
- Forventet resultat: PEGI 3 / Alle

### Målgruppe
- Aldersgrupper: **13–15, 16–17 og 18+**
- Ikke velg under 13 år. Da gjelder Googles Families-regler, som krever mer dokumentasjon.
- Appen er ikke rettet mot barn.

### Nyhetsapp / helseapp / statlig app / finansfunksjoner
**Nei** på nyhet, statlig og finans. I skjemaet for **helseapper**: appen er en generell vanesporer uten helsedata, sensorer eller medisinske funksjoner. Velg «Ingen av disse» hvis det er et valg. Hvis ikke, velg det nærmeste alternativet for livsstil eller velvære.

---

## Kjøp i appen (TipJar)

Produktene kan først opprettes **etter** at en AAB med billing er lastet opp (den er med via `in_app_purchase`). Det krever også en **betalingsprofil** (Payments profile) i Play Console.

Lag tre **engangsprodukter** (One-time products). Appen bruker dem som forbruksvarer:

| Produkt-ID | Navn | Pris |
| --- | --- | --- |
| `karos_habits_tip_29` | Small tip | NOK 29 |
| `karos_habits_tip_59` | Medium tip | NOK 59 |
| `karos_habits_tip_99` | Large tip | NOK 99 |

Beskrivelse (alle): *"A tip to support Karos Habits. Thank you!"*

Knappene viser automatisk lokal pris fra Google Play. NOK-teksten brukes bare før produktene er lastet.

---

## Lukket test med 12 testere (krav for nye personlige kontoer)

Google krever at nye personlige utviklerkontoer har en **lukket test med minst 12 testere som har meldt seg på, sammenhengende i 14 dager**, før du kan søke om produksjon.

1. **Lag appen** i Play Console: navn *Karos Habits*, standardspråk English (US), app, gratis.
2. **Fyll ut Appinnhold** (over) og **Store listing**.
3. **Bygg** (se README.md for signering):
   ```bash
   flutter build appbundle
   ```
   Fila havner i `build/app/outputs/bundle/release/app-release.aab`.
4. **Testing → Lukket testing → Opprett spor** (eller bruk «Alpha»):
   - Testere: lag en **e-postliste** med de 12+ Google-kontoene (Gmail-adressene de bruker i Play Butikk), eller bruk en Google-gruppe.
   - Land: Norge (og ev. andre der testerne bor).
   - Last opp AAB-en og skriv utgivelsesnotat, f.eks. *"First test version. Please use the app daily and send feedback via Info → Send me a letter."*
   - Send til gjennomgang. Den første gjennomgangen kan ta noen dager.
5. **Del påmeldingslenken** («Join on the web») med testerne når sporet er godkjent. Hver tester må
   - åpne lenken mens de er logget inn med samme Google-konto som står på lista,
   - trykke **«Become a tester»**,
   - installere appen fra Play Butikk via lenken.
6. **Hold testerne aktive i 14 dager.** Det er antall *påmeldte* som teller, men Google ser også på om appen faktisk blir brukt. Be dem åpne den noen ganger i uka. Gjerne én oppdatering underveis (versionCode 13) med små rettelser.
7. Etter 14 dager: **Dashboard → «Søk om tilgang til produksjon»**. Svar på spørsmålene om testingen: hvor mange testere, hva de ga tilbakemelding om, og hva du endret.

**Tips til rekruttering:** Det er nok at 12 personer er påmeldt samtidig gjennom hele perioden. Ta gjerne med 14–15, i tilfelle noen faller fra. Når noen melder seg av, kan klokka starte på nytt hvis dere havner under 12.

---

## Sjekkliste før opplasting

- [ ] `android/key.properties` + `upload-keystore.jks` laget (se README.md), og backup tatt
- [ ] `flutter build appbundle` med release-nøkkelen
- [ ] Play App Signing slått på (standard for nye apper)
- [ ] Store listing, grafikk og alle punkter under Appinnhold fylt ut
- [ ] Personvernsiden oppdatert med TipJar-setningen
- [ ] Lukket test opprettet og 12+ testere lagt inn

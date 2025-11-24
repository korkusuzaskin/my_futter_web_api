import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Borsa Kahini',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        cardColor: Colors.white,
        dividerColor: Colors.grey[300],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: Colors.grey[800],
      ),
      home: const BorsaEkrani(),
    );
  }
}

class BorsaEkrani extends StatefulWidget {
  const BorsaEkrani({super.key});

  @override
  State<BorsaEkrani> createState() => _BorsaEkraniState();
}

class _BorsaEkraniState extends State<BorsaEkrani> {
  TextEditingController? _autocompleteController;

  bool _isLoading = false;
  bool _isPortfolioLoading = false;

  bool _analizTamamlandi = false;
  String _errorMessage = "";
  String? _sembol;
  String? _sembolKodu;
  String? _veriTarihi;
  String? _guncelFiyat;
  String? _oncekiKapanis;
  String? _degisimOrani;
  String? _hedefTarihi;
  String? _tahminFiyat;
  String? _fark;
  String? _sinyal;
  String? _guncelZaman;

  int? _acikPanelIndex;
  String _aramaMetni = "";
  int _secilenGun = 1;

  List<double>? _gecmisFiyatlar;
  List<String>? _gecmisTarihler;

  final List<String> _kullaniciHisseleri = [];
  double _userKarAl = 10.0;
  double _userDipAl = 5.0;

  final String _baseUrl = Platform.isAndroid
      ? 'https://borsa-api-ompc.onrender.com'
      : 'http://127.0.0.1:5000';

  // --- VERİ LİSTELERİ ---
  final List<Map<String, String>> _bist30 = [
    {'isim': 'AKBANK', 'kod': 'AKBNK.IS'}, {'isim': 'AKSA', 'kod': 'AKSA.IS'}, {'isim': 'ALARKO', 'kod': 'ALARK.IS'},
    {'isim': 'ARCELIK', 'kod': 'ARCLK.IS'}, {'isim': 'ASELSAN', 'kod': 'ASELS.IS'}, {'isim': 'ASTOR', 'kod': 'ASTOR.IS'},
    {'isim': 'BIM', 'kod': 'BIMAS.IS'}, {'isim': 'BORUSAN', 'kod': 'BRSAN.IS'}, {'isim': 'EKGYO', 'kod': 'EKGYO.IS'},
    {'isim': 'ENKA', 'kod': 'ENKAI.IS'}, {'isim': 'EREGLI', 'kod': 'EREGL.IS'}, {'isim': 'FORD OTO', 'kod': 'FROTO.IS'},
    {'isim': 'FENERBAHÇE', 'kod': 'FENER.IS'},{'isim': 'GARANTI', 'kod': 'GARAN.IS'}, {'isim': 'GUBRE FAB', 'kod': 'GUBRF.IS'},
    {'isim': 'HEKTAS', 'kod': 'HEKTS.IS'}, {'isim': 'IS BANKASI', 'kod': 'ISCTR.IS'}, {'isim': 'KOC HOLDING', 'kod': 'KCHOL.IS'},
    {'isim': 'KONTR', 'kod': 'KONTR.IS'}, {'isim': 'KOZA ALTIN', 'kod': 'KOZAL.IS'}, {'isim': 'KARDEMIR D', 'kod': 'KRDMD.IS'},
    {'isim': 'ODAS', 'kod': 'ODAS.IS'}, {'isim': 'OYAK CIMENTO', 'kod': 'OYAKC.IS'}, {'isim': 'PETKIM', 'kod': 'PETKM.IS'},
    {'isim': 'PEGASUS', 'kod': 'PGSUS.IS'}, {'isim': 'SABANCI', 'kod': 'SAHOL.IS'}, {'isim': 'SASA', 'kod': 'SASA.IS'},
    {'isim': 'SISECAM', 'kod': 'SISE.IS'}, {'isim': 'TAV', 'kod': 'TAVHL.IS'}, {'isim': 'TURKCELL', 'kod': 'TCELL.IS'},
    {'isim': 'THY', 'kod': 'THYAO.IS'}, {'isim': 'TOFAS', 'kod': 'TOASO.IS'}, {'isim': 'TSKB', 'kod': 'TSKB.IS'},
    {'isim': 'TURK TELEKOM', 'kod': 'TTKOM.IS'}, {'isim': 'TUPRAS', 'kod': 'TUPRS.IS'}, {'isim': 'VAKIFBANK', 'kod': 'VAKBN.IS'},
    {'isim': 'VESTEL', 'kod': 'VESTL.IS'}, {'isim': 'YAPI KREDI', 'kod': 'YKBNK.IS'}
  ];

  final List<Map<String, String>> _bist100 = [
    {'isim': 'ANADOLU EFES', 'kod': 'AEFES.IS'}, {'isim': 'AGOT', 'kod': 'AGHOL.IS'}, {'isim': 'AKCANSA', 'kod': 'AKCNS.IS'},
    {'isim': 'AKSEN', 'kod': 'AKSEN.IS'}, {'isim': 'ALBARAKA', 'kod': 'ALBRK.IS'}, {'isim': 'ASCE GYO', 'kod': 'ASGYO.IS'},
    {'isim': 'AYDEM', 'kod': 'AYDEM.IS'}, {'isim': 'AYGAZ', 'kod': 'AYGAZ.IS'}, {'isim': 'BERA', 'kod': 'BERA.IS'},
    {'isim': 'BIOTREND', 'kod': 'BIOEN.IS'}, {'isim': 'BOGAZICI BETON', 'kod': 'BOBET.IS'}, {'isim': 'BRISA', 'kod': 'BRISA.IS'},
    {'isim': 'BUCIM', 'kod': 'BUCIM.IS'}, {'isim': 'CAN2 TERMIK', 'kod': 'CANTE.IS'}, {'isim': 'CCOLA', 'kod': 'CCOLA.IS'},
    {'isim': 'CEMTAS', 'kod': 'CEMTS.IS'}, {'isim': 'CIMSA', 'kod': 'CIMSA.IS'}, {'isim': 'CW ENERJI', 'kod': 'CWENE.IS'},
    {'isim': 'DOGUS OTO', 'kod': 'DOAS.IS'}, {'isim': 'DOHOL', 'kod': 'DOHOL.IS'}, {'isim': 'ECZACIBASI ILAC', 'kod': 'ECILC.IS'},
    {'isim': 'EGE ENDUSTRI', 'kod': 'EGEEN.IS'}, {'isim': 'ENERJISA', 'kod': 'ENJSA.IS'}, {'isim': 'EUREN', 'kod': 'EUREN.IS'},
    {'isim': 'FENERBAHCE', 'kod': 'FENER.IS'}, {'isim': 'GALATA WIND', 'kod': 'GWIND.IS'}, {'isim': 'GALATASARAY', 'kod': 'GSRAY.IS'},
    {'isim': 'GEN ILAC', 'kod': 'GENIL.IS'}, {'isim': 'GESAN', 'kod': 'GESAN.IS'}, {'isim': 'GLOBAL YATIRIM', 'kod': 'GLYHO.IS'},
    {'isim': 'GOZDE GIRISIM', 'kod': 'GOZDE.IS'}, {'isim': 'HALKBANK', 'kod': 'HALKB.IS'}, {'isim': 'IPEK ENERJI', 'kod': 'IPEKE.IS'},
    {'isim': 'IS GYO', 'kod': 'ISGYO.IS'}, {'isim': 'IS MENKUL', 'kod': 'ISMEN.IS'}, {'isim': 'KALE SERAMIK', 'kod': 'KLSER.IS'},
    {'isim': 'KIMTEKS', 'kod': 'KMPUR.IS'}, {'isim': 'KONYA CIMENTO', 'kod': 'KONYA.IS'}, {'isim': 'KOROPLAST', 'kod': 'KRPLS.IS'},
    {'isim': 'LOGO YAZILIM', 'kod': 'LOGO.IS'}, {'isim': 'MAVI', 'kod': 'MAVI.IS'}, {'isim': 'MIGROS', 'kod': 'MGROS.IS'},
    {'isim': 'MLP SAGLIK', 'kod': 'MPARK.IS'}, {'isim': 'NATUREL GAZ', 'kod': 'NTGAZ.IS'}, {'isim': 'NUH CIMENTO', 'kod': 'NUHCM.IS'},
    {'isim': 'OTKAR', 'kod': 'OTKAR.IS'}, {'isim': 'OYAK YATIRIM', 'kod': 'OYYAT.IS'}, {'isim': 'PENTA', 'kod': 'PENTA.IS'},
    {'isim': 'QUAGR', 'kod': 'QUAGR.IS'}, {'isim': 'REEDER', 'kod': 'REEDR.IS'}, {'isim': 'SARKUYSAN', 'kod': 'SARKY.IS'},
    {'isim': 'SOK MARKET', 'kod': 'SOKM.IS'}, {'isim': 'TAT GIDA', 'kod': 'TATGD.IS'}, {'isim': 'TUKAS', 'kod': 'TUKAS.IS'},
    {'isim': 'TURK ILAC', 'kod': 'TRILC.IS'}, {'isim': 'TRAKTOR', 'kod': 'TTRAK.IS'}, {'isim': 'ULKER', 'kod': 'ULKER.IS'},
    {'isim': 'VERUSA', 'kod': 'VERUS.IS'}, {'isim': 'YATAS', 'kod': 'YATAS.IS'}, {'isim': 'YEO TEKNOLOJI', 'kod': 'YEOTK.IS'},
    {'isim': 'ZOREN', 'kod': 'ZOREN.IS'}
  ];

  final List<Map<String, String>> _abdHisseler = [
    {'isim': 'APPLE', 'kod': 'AAPL'}, {'isim': 'MICROSOFT', 'kod': 'MSFT'}, {'isim': 'NVIDIA', 'kod': 'NVDA'},
    {'isim': 'AMAZON', 'kod': 'AMZN'}, {'isim': 'GOOGLE (A)', 'kod': 'GOOGL'}, {'isim': 'META (FACEBOOK)', 'kod': 'META'},
    {'isim': 'TESLA', 'kod': 'TSLA'}, {'isim': 'BERKSHIRE HATHAWAY', 'kod': 'BRK-B'}, {'isim': 'TSMC', 'kod': 'TSM'},
    {'isim': 'ELI LILLY', 'kod': 'LLY'}, {'isim': 'BROADCOM', 'kod': 'AVGO'}, {'isim': 'JPMORGAN', 'kod': 'JPM'},
    {'isim': 'VISA', 'kod': 'V'}, {'isim': 'EXXON MOBIL', 'kod': 'XOM'}, {'isim': 'UNITEDHEALTH', 'kod': 'UNH'},
    {'isim': 'MASTERCARD', 'kod': 'MA'}, {'isim': 'PROCTER & GAMBLE', 'kod': 'PG'}, {'isim': 'JOHNSON & JOHNSON', 'kod': 'JNJ'},
    {'isim': 'COSTCO', 'kod': 'COST'}, {'isim': 'HOME DEPOT', 'kod': 'HD'}, {'isim': 'MERCK', 'kod': 'MRK'},
    {'isim': 'ABBVIE', 'kod': 'ABBV'}, {'isim': 'NETFLIX', 'kod': 'NFLX'}, {'isim': 'AMD', 'kod': 'AMD'},
    {'isim': 'PEPSICO', 'kod': 'PEP'}, {'isim': 'BANK OF AMERICA', 'kod': 'BAC'}, {'isim': 'CHEVRON', 'kod': 'CVX'},
    {'isim': 'COCA-COLA', 'kod': 'KO'}, {'isim': 'WALMART', 'kod': 'WMT'}, {'isim': 'ADOBE', 'kod': 'ADBE'},
    {'isim': 'SALESFORCE', 'kod': 'CRM'}, {'isim': 'ORACLE', 'kod': 'ORCL'}, {'isim': 'MCDONALDS', 'kod': 'MCD'},
    {'isim': 'CISCO', 'kod': 'CSCO'}, {'isim': 'INTEL', 'kod': 'INTC'}, {'isim': 'QUALCOMM', 'kod': 'QCOM'},
    {'isim': 'DISNEY', 'kod': 'DIS'}, {'isim': 'NIKE', 'kod': 'NKE'}, {'isim': 'PFIZER', 'kod': 'PFE'},
    {'isim': 'BOEING', 'kod': 'BA'}, {'isim': 'IBM', 'kod': 'IBM'}, {'isim': 'AT&T', 'kod': 'T'},
    {'isim': 'VERIZON', 'kod': 'VZ'}, {'isim': 'GOLDMAN SACHS', 'kod': 'GS'}, {'isim': 'MORGAN STANLEY', 'kod': 'MS'},
    {'isim': 'CITIGROUP', 'kod': 'C'}, {'isim': 'STARBUCKS', 'kod': 'SBUX'}, {'isim': 'GE', 'kod': 'GE'},
    {'isim': '3M', 'kod': 'MMM'}, {'isim': 'CATERPILLAR', 'kod': 'CAT'}
  ];

  final List<Map<String, String>> _kriptolar = [
    {'isim': 'BITCOIN', 'kod': 'BTC-USD'}, {'isim': 'ETHEREUM', 'kod': 'ETH-USD'}, {'isim': 'BNB', 'kod': 'BNB-USD'},
    {'isim': 'SOLANA', 'kod': 'SOL-USD'}, {'isim': 'XRP', 'kod': 'XRP-USD'}, {'isim': 'DOGECOIN', 'kod': 'DOGE-USD'},
    {'isim': 'CARDANO', 'kod': 'ADA-USD'}, {'isim': 'AVALANCHE', 'kod': 'AVAX-USD'}, {'isim': 'SHIBA INU', 'kod': 'SHIB-USD'},
    {'isim': 'POLKADOT', 'kod': 'DOT-USD'}, {'isim': 'TRON', 'kod': 'TRX-USD'}, {'isim': 'CHAINLINK', 'kod': 'LINK-USD'},
    {'isim': 'POLYGON', 'kod': 'MATIC-USD'}, {'isim': 'LITECOIN', 'kod': 'LTC-USD'}, {'isim': 'BITCOIN CASH', 'kod': 'BCH-USD'},
    {'isim': 'NEAR PROTOCOL', 'kod': 'NEAR-USD'}, {'isim': 'UNISWAP', 'kod': 'UNI-USD'}, {'isim': 'ICP', 'kod': 'ICP-USD'},
    {'isim': 'APTOS', 'kod': 'APT-USD'}, {'isim': 'STELLAR', 'kod': 'XLM-USD'}, {'isim': 'ETHEREUM CLASSIC', 'kod': 'ETC-USD'},
    {'isim': 'VECHAIN', 'kod': 'VET-USD'}, {'isim': 'FILECOIN', 'kod': 'FIL-USD'}, {'isim': 'ATOM (COSMOS)', 'kod': 'ATOM-USD'},
    {'isim': 'ARBITRUM', 'kod': 'ARB-USD'}, {'isim': 'OPTIMISM', 'kod': 'OP-USD'}, {'isim': 'RENDER', 'kod': 'RNDR-USD'},
    {'isim': 'INJECTIVE', 'kod': 'INJ-USD'}, {'isim': 'GRT', 'kod': 'GRT-USD'}, {'isim': 'FANTOM', 'kod': 'FTM-USD'},
    {'isim': 'THETA', 'kod': 'THETA-USD'}, {'isim': 'SANDBOX', 'kod': 'SAND-USD'}, {'isim': 'DECENTRALAND', 'kod': 'MANA-USD'},
    {'isim': 'AXIE INFINITY', 'kod': 'AXS-USD'}, {'isim': 'ALGORAND', 'kod': 'ALGO-USD'}, {'isim': 'AAVE', 'kod': 'AAVE-USD'},
    {'isim': 'FLOW', 'kod': 'FLOW-USD'}, {'isim': 'EOS', 'kod': 'EOS-USD'}, {'isim': 'TEZOS', 'kod': 'XTZ-USD'},
    {'isim': 'NEO', 'kod': 'NEO-USD'}, {'isim': 'IOTA', 'kod': 'IOTA-USD'}, {'isim': 'GALA', 'kod': 'GALA-USD'},
    {'isim': 'CHILIZ', 'kod': 'CHZ-USD'}, {'isim': 'MAKER', 'kod': 'MKR-USD'}, {'isim': 'SYNTHETIX', 'kod': 'SNX-USD'},
    {'isim': 'PEPE', 'kod': 'PEPE-USD'}, {'isim': 'BONK', 'kod': 'BONK-USD'}, {'isim': 'FLOKI', 'kod': 'FLOKI-USD'},
    {'isim': 'SUI', 'kod': 'SUI-USD'}, {'isim': 'SEI', 'kod': 'SEI-USD'}
  ];

  final List<Map<String, String>> _emtialar = [
    {'isim': 'ALTIN (Ons)', 'kod': 'GC=F'}, {'isim': 'GUMUS', 'kod': 'SI=F'}, {'isim': 'PLATIN', 'kod': 'PL=F'},
    {'isim': 'PALADYUM', 'kod': 'PA=F'}, {'isim': 'BAKIR', 'kod': 'HG=F'}, {'isim': 'HAM PETROL (WTI)', 'kod': 'CL=F'},
    {'isim': 'BRENT PETROL', 'kod': 'BZ=F'}, {'isim': 'DOGALGAZ', 'kod': 'NG=F'}, {'isim': 'BENZIN', 'kod': 'RB=F'},
    {'isim': 'ISINMA YAKITI', 'kod': 'HO=F'}, {'isim': 'MISIR', 'kod': 'ZC=F'}, {'isim': 'SOYA FASULYESI', 'kod': 'ZS=F'},
    {'isim': 'BUGDAY', 'kod': 'ZW=F'}, {'isim': 'KAKAO', 'kod': 'CC=F'}, {'isim': 'KAHVE', 'kod': 'KC=F'},
    {'isim': 'PAMUK', 'kod': 'CT=F'}, {'isim': 'SEKER', 'kod': 'SB=F'}, {'isim': 'CANLI SIGIR', 'kod': 'LE=F'},
    {'isim': 'BESI SIGIRI', 'kod': 'GF=F'}, {'isim': 'KERESTE', 'kod': 'LBS=F'}
  ];

  List<Map<String, String>> get _tumVarliklar => [..._bist30, ..._bist100, ..._abdHisseler, ..._kriptolar, ..._emtialar];

  String fiyatFormatla(dynamic gelenFiyat) {
    double fiyat = double.tryParse(gelenFiyat.toString()) ?? 0.0;
    if (fiyat >= 1.0) return fiyat.toStringAsFixed(2);
    return fiyat.toStringAsFixed(4);
  }

  String isimGetir(String kod) {
    for (var item in _tumVarliklar) {
      if (item['kod'] == kod) {
        return item['isim']!;
      }
    }
    return kod;
  }

  String koduBul(String girilenYazi) {
    String aranan = girilenYazi.toUpperCase().trim();
    var bulunan = _tumVarliklar.firstWhere(
      (element) => element['isim'] == aranan || element['kod'] == aranan,
      orElse: () => {'kod': aranan, 'isim': aranan},
    );
    return bulunan['kod']!;
  }

  // --- ANALİZ ---
  Future<void> analizEt(String kod, {int gun = 1}) async {
    _autocompleteController?.clear();
    _aramaMetni = "";

    setState(() {
        _isLoading = true;
        _analizTamamlandi = false;
        _errorMessage = "";
        _gecmisFiyatlar = null;
        _gecmisTarihler = null;
        _secilenGun = gun;
    });

    try {
      final response = await http.post(Uri.parse('$_baseUrl/analiz'),
        headers: {'Content-Type': 'application/json; charset=UTF-8', 'x-api-key': 'gizli_super_sifre_2025'},
        body: jsonEncode({'sembol': kod, 'gun_sayisi': gun}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _sembolKodu = data['hisse'];
          _sembol = isimGetir(data['hisse']);
          _guncelFiyat = fiyatFormatla(data['fiyat']);
          _oncekiKapanis = fiyatFormatla(data['onceki_kapanis']);
          _degisimOrani = data['degisim_orani'].toString();
          _tahminFiyat = fiyatFormatla(data['tahmin']);
          _veriTarihi = data['veri_tarihi'];
          _hedefTarihi = data['hedef_tarihi'];
          _fark = data['fark'].toString();
          _sinyal = data['sinyal'];
          _guncelZaman = data['guncel_zaman'];
          _gecmisFiyatlar = (data['gecmis_fiyatlar'] as List).map((e) => double.parse(e.toString())).toList();
          _gecmisTarihler = (data['gecmis_tarihler'] as List).map((e) => e.toString()).toList();
          _analizTamamlandi = true;
        });
      } else { setState(() { _errorMessage = "Hata: ${response.statusCode}"; }); }
    } catch (e) { setState(() { _errorMessage = "Sunucu Baglanti Hatasi!"; }); }
    finally { setState(() { _isLoading = false; }); }
  }

  // --- PORTFÖY SİMÜLASYONU ---
  Future<void> portfoyTesti(
  List<String> kodlar,
  double karAl,
  double dipAl, {
  int gunSayisi = 30,
}) async {
  if (kodlar.isEmpty) return;

  if (!mounted) return; // 🔥 widget hâlâ yaşıyor mu kontrol et
  setState(() {
    _isPortfolioLoading = true;
  });

  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/portfoy_simulasyon'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': 'gizli_super_sifre_2025',
      },
      body: jsonEncode({
        'semboller': kodlar,
        'kar_al_orani': karAl,
        'dip_al_orani': dipAl,
        'gun_sayisi': gunSayisi,
      }),
    );

    if (!mounted) return; // 🔥 await sonrası tekrar kontrol et

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      _portfoySonucPenceresi(data, kodlar, karAl, dipAl, gunSayisi);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${response.statusCode}")),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sunucu Baglanti Hatasi!")),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isPortfolioLoading = false;
      });
    }
  }
}

  // --- KENDİN OLUŞTUR PENCERESİ ---
  void _kullaniciPortfoyPenceresi() {
  TextEditingController localController = TextEditingController();
  FocusNode focusNode = FocusNode(); // Seri giriş için FocusNode

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        void hisseEkle() {
          String hamMetin = localController.text.toUpperCase();
          if (hamMetin.isEmpty) return;

          List<String> parcalar = hamMetin.split(RegExp(r'[,\s]+'));
          bool degisiklikYapildi = false;

          for (var parca in parcalar) {
            String temizIsimVeyaKod = parca.trim();
            if (temizIsimVeyaKod.isNotEmpty) {
              String kod = koduBul(temizIsimVeyaKod);

              if (!_kullaniciHisseleri.contains(kod)) {
                _kullaniciHisseleri.add(kod);
                degisiklikYapildi = true;
              }
            }
          }

          if (degisiklikYapildi) {
            setModalState(() {
              localController.clear();
            });
            focusNode.requestFocus(); // İmleci kutuda tut
          }
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Kendi Portfoyunu Olustur",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: localController,
                      focusNode: focusNode, // ✅ burada da düzeltildi
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                          hintText: "Kod veya Isim Gir (Apple, THYAO)..."),
                      onChanged: (val) {
                        localController.value = localController.value.copyWith(
                          text: val.toUpperCase(),
                          selection:
                              TextSelection.collapsed(offset: val.length),
                        );
                      },
                      onSubmitted: (_) => hisseEkle(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Colors.green, size: 32),
                    onPressed: hisseEkle,
                  )
                ],
              ),

                const SizedBox(height: 10),
                // Kaydırılabilir Liste Alanı
                Container(
                  height: 150, // Sabit yükseklik
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                  child: _kullaniciHisseleri.isEmpty
                    ? const Center(child: Text("Henuz hisse eklemediniz."))
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _kullaniciHisseleri.map((hisse) => Chip(
                              label: Text(isimGetir(hisse)),
                              onDeleted: () {
                                setModalState(() { _kullaniciHisseleri.remove(hisse); });
                              },
                            )).toList(),
                          ),
                        ),
                      ),
                ),

                const Divider(),
                Text("Strateji Ayarlari", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),

                Row(children: [const Text("Kar Al:", style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Slider(value: _userKarAl, min: 1, max: 20, divisions: 19, label: "%$_userKarAl", onChanged: (val) => setModalState(() => _userKarAl = val))), Text("%${_userKarAl.toInt()}")]),
                Row(children: [const Text("Dipten Al:", style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Slider(value: _userDipAl, min: 1, max: 20, divisions: 19, label: "%$_userDipAl", activeColor: Colors.red, onChanged: (val) => setModalState(() => _userDipAl = val))), Text("%${_userDipAl.toInt()}")]),

                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("SIMULASYONU BASLAT"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                    onPressed: _kullaniciHisseleri.isEmpty ? null : () {
                      Navigator.pop(context);
                      // Hesaplama Hatası Düzeltildi: Kodları doğru fonksiyona gönderiyoruz
                      portfoyTesti(_kullaniciHisseleri, _userKarAl, _userDipAl);
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _kategoriSecimPenceresi() {
    showModalBottomSheet(context: context, builder: (BuildContext bc) {
      return SafeArea(
        child: Wrap(children: <Widget>[
          ListTile(leading: const Icon(Icons.edit, color: Colors.purple), title: const Text('Kendin Olustur'), onTap: () { Navigator.pop(context); _kullaniciPortfoyPenceresi(); }),
          const Divider(),
          ExpansionTile(
            leading: const Icon(Icons.trending_up, color: Colors.blue),
            title: const Text('BIST Portfoyleri'),
            children: [
              ListTile(title: const Text('BIST 30 (30 Hisse)'), onTap: () { Navigator.pop(context); portfoyTesti(_bist30.map((e)=>e['kod']!).toList(), 8.0, 7.0); }),
              ListTile(title: const Text('BIST 100 (Orneklem)'), onTap: () { Navigator.pop(context); portfoyTesti(_bist100.map((e)=>e['kod']!).toList(), 8.0, 7.0); }),
            ],
          ),
          ListTile(leading: const Icon(Icons.flag, color: Colors.indigo), title: const Text('ABD Devleri (50 Hisse)'), onTap: () { Navigator.pop(context); portfoyTesti(_abdHisseler.map((e)=>e['kod']!).toList(), 8.0, 7.0); }),
          ListTile(leading: const Icon(Icons.currency_bitcoin, color: Colors.orange), title: const Text('Kripto Sepeti (50 Coin)'), onTap: () { Navigator.pop(context); portfoyTesti(_kriptolar.map((e)=>e['kod']!).toList(), 15.0, 10.0); }),
          ListTile(leading: const Icon(Icons.diamond, color: Colors.brown), title: const Text('Emtia Sepeti (20 Emtia)'), onTap: () { Navigator.pop(context); portfoyTesti(_emtialar.map((e)=>e['kod']!).toList(), 5.0, 4.0); }),
        ]),
      );
    });
  }

  // 🔥 GÜN SEÇİMİ EKLENMİŞ PORTFÖY SONUÇ PENCERESİ
  void _portfoySonucPenceresi(Map<String, dynamic> data, List<String> kodlar, double kar, double dip, int gun) {
    double karZarar = double.parse(data['kar_zarar'].toString());
    bool karli = karZarar >= 0;
    List<dynamic> detaylar = data['detaylar'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: karli ? Colors.green.shade50 : Colors.red.shade50,
            title: const Text("Gelecek K/Z Simulasyonlari", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: SizedBox(
              height: 400,
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TAHMİN VADESİ SEÇİMİ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Vade Secimi:", style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<int>(
                        value: gun,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("1 Gun")),
                          DropdownMenuItem(value: 7, child: Text("1 Hafta")),
                          DropdownMenuItem(value: 30, child: Text("1 Ay")),
                        ],
                        onChanged: (yeniGun) {
                          if (yeniGun != null) {
                            Navigator.pop(context); // Mevcut pencereyi kapat
                            portfoyTesti(kodlar, kar, dip, gunSayisi: yeniGun); // Yeniden hesapla
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  Text("Yatirim: 10,000 \$", style: TextStyle(color: Colors.grey.shade700)),
                  Text("Tahmini Sonuc: ${data['bitis']} \$", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: karli ? Colors.green.shade800 : Colors.red.shade800)),
                  Text("Ongorulen Kar: ${data['kar_zarar']} \$ (%${data['yuzde']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  const SizedBox(height: 10),
                  Center(child: ElevatedButton.icon(icon: const Icon(Icons.table_chart), label: const Text("Detayli Tabloyu Goster"), onPressed: () { Navigator.pop(ctx); _detayliTabloGoster(detaylar); }))
                ]
              )
            ),
            actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Kapat"))]
          );
        }
      )
    );
  }

void _detayliTabloGoster(List<dynamic> detaylar) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Üst Bar (AppBar benzeri)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Portföy Detayları",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text("Raporu Kopyala"),
                    onPressed: () {
                      String kopyalanacakMetin =
                          "Varlik\tAlis\tSatis\tNot\tKar/Zarar\n";
                      for (var item in detaylar) {
                        kopyalanacakMetin +=
                            "${isimGetir(item['ticker'])}\t${fiyatFormatla(item['giris_fiyati'])}\t${fiyatFormatla(item['cikis_fiyati'])}\t${item['strateji_notu']}\t%${item['yuzde']}\n";
                      }
                      Clipboard.setData(ClipboardData(text: kopyalanacakMetin));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Tablo kopyalandi! Excel veya Word'e yapistirabilirsiniz."),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),

          // Tablo
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('Varlık', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Giriş', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Çıkış', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Not', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Yüzde', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: detaylar.map((item) {
                    double yuzde = double.parse(item['yuzde'].toString());
                    bool isProfit = yuzde >= 0;

                    return DataRow(cells: [
                      DataCell(Row(children: [
                        const Icon(Icons.pie_chart, size: 16, color: Colors.blueGrey),
                        const SizedBox(width: 5),
                        Text(isimGetir(item['ticker']), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ])),
                      DataCell(Text(fiyatFormatla(item['giris_fiyati']))),
                      DataCell(Text(fiyatFormatla(item['cikis_fiyati']))),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['strateji_notu'] ?? "-"),
                            Text("Fiyat: ${item['giris_fiyati']}", style: const TextStyle(color: Colors.blueGrey)),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          "%${yuzde.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: isProfit ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]);
                  }).toList(), // 🔥 Iterable → List<DataRow>
                ),
              ),
            ),
          ),

         // Alt Kapat Butonu
         ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Kapat"),
         ),
       ],
     ),
   ),
 );
}

  Widget _buildChip(Map<String, String> varlik, Color renk, Color yaziRengi) {
    return ActionChip(
      backgroundColor: renk,
      label: Text(varlik['isim']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: yaziRengi)),
      onPressed: () {
        _autocompleteController?.text = varlik['kod']!;
        analizEt(varlik['kod']!);
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor, Color textColor, Color labelColor) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Row(children: [Icon(icon, size: 18, color: iconColor), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: labelColor)), const Spacer(), Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor))))]));
  }

  Widget _buildKategoriPaneli(int index, String baslik, IconData ikon, Color temaRengi, List<Map<String, String>> liste, Color chipBg, Color chipText) {
    return Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        key: Key(index.toString() + (_acikPanelIndex == index).toString()),
        initiallyExpanded: _acikPanelIndex == index,
        onExpansionChanged: (isOpen) { if (isOpen) { setState(() { _acikPanelIndex = index; }); } else { setState(() { _acikPanelIndex = null; }); } },
        leading: Icon(ikon, color: temaRengi),
        title: Text(baslik, style: TextStyle(fontWeight: FontWeight.bold, color: temaRengi)),
        children: [Padding(padding: const EdgeInsets.all(12.0), child: Wrap(spacing: 8.0, runSpacing: 8.0, children: liste.map((v) => _buildChip(v, chipBg, chipText)).toList()))],
      ),
    );
  }

  Widget _buildGrafikKutusu(Color grafikRengi, Color zeminRengi, bool isDarkMode) {
    if (_gecmisFiyatlar == null || _gecmisFiyatlar!.isEmpty) return const SizedBox();

    double minFiyat = _gecmisFiyatlar!.reduce((curr, next) => curr < next ? curr : next);
    double maxFiyat = _gecmisFiyatlar!.reduce((curr, next) => curr > next ? curr : next);

    List<FlSpot> spots = [];
    for (int i = 0; i < _gecmisFiyatlar!.length; i++) {
      spots.add(FlSpot(i.toDouble(), _gecmisFiyatlar![i]));
    }

    Color titleColor = zeminRengi == Colors.white
        ? (isDarkMode ? Colors.white70 : Colors.black54)
        : Colors.black.withValues(alpha: 0.7);

    Color tooltipBgColor = zeminRengi != Colors.white
        ? Colors.white
        : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200);

    Color tooltipTextColor = zeminRengi != Colors.white
        ? grafikRengi
        : (isDarkMode ? Colors.white : Colors.black);

    return Card(
      elevation: 6,
      color: zeminRengi == Colors.white
          ? (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white)
          : zeminRengi,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 320,
        child: Column(
          children: [
            Text(
              "Son 30 Günlük Fiyat Hareketi",
              style: TextStyle(fontWeight: FontWeight.bold, color: titleColor),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < _gecmisTarihler!.length) {
                            if (index % 5 == 0 || index == _gecmisTarihler!.length - 1) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  _gecmisTarihler![index],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: zeminRengi != Colors.white
                                        ? Colors.black
                                        : (isDarkMode ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                              );
                            }
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minFiyat * 0.99,
                  maxY: maxFiyat * 1.01,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => tooltipBgColor,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          int index = barSpot.x.toInt();
                          String tarih = _gecmisTarihler != null && index < _gecmisTarihler!.length
                              ? _gecmisTarihler![index]
                              : "";
                          return LineTooltipItem(
                            "$tarih\n${barSpot.y.toStringAsFixed(2)}",
                            TextStyle(
                              color: tooltipTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: grafikRengi,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        // 🔥 withOpacity yerine withValues
                        color: grafikRengi.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    Color zeminRengi, grafikRengi, yaziRengi, etiketRengi;
    if (_sinyal != null && _sinyal!.contains("AL")) { zeminRengi = Colors.yellow.shade400; grafikRengi = Colors.blue.shade900; yaziRengi = Colors.blue.shade900; etiketRengi = Colors.blue.shade800; }
    else if (_sinyal != null && _sinyal!.contains("SAT")) { zeminRengi = const Color(0xFFFFE0B2); grafikRengi = Colors.red.shade900; yaziRengi = Colors.red.shade900; etiketRengi = Colors.red.shade800; }
    else { zeminRengi = Colors.white; grafikRengi = Colors.grey; yaziRengi = isDarkMode ? Colors.white : Colors.black87; etiketRengi = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700; }
    Color cardBackground = zeminRengi == Colors.white ? (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white) : zeminRengi;
    Color infoBoxColor = zeminRengi != Colors.white ? Colors.white : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100);
    bool isPositive = _degisimOrani != null && !_degisimOrani!.startsWith("-");
    Color degisimRengi = isPositive ? Colors.green.shade700 : Colors.red.shade700;
    IconData degisimIkonu = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    if (zeminRengi != Colors.white) degisimRengi = Colors.black87;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Borsa Kahini', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), centerTitle: true, backgroundColor: Colors.blueAccent),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[

              Card(
                elevation: 6, color: Colors.yellow, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                  child: Autocomplete<Map<String, String>>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') return const Iterable.empty();
                      return _tumVarliklar.where((Map<String, String> option) {
                        return option['isim']!.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                               option['kod']!.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (Map<String, String> selection) {
                      _aramaMetni = selection['kod']!;
                      analizEt(selection['kod']!);
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(alignment: Alignment.topLeft, child: Material(elevation: 4.0, child: Container(width: MediaQuery.of(context).size.width - 60, color: Colors.white, child: ListView.builder(padding: EdgeInsets.zero, shrinkWrap: true, itemCount: options.length, itemBuilder: (BuildContext context, int index) { final option = options.elementAt(index); return ListTile(title: Text(option['isim']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)), subtitle: Text(option['kod']!, style: TextStyle(color: Colors.grey.shade700)), onTap: () => onSelected(option)); }))));
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      _autocompleteController = textEditingController;
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        textInputAction: TextInputAction.search,
                        textCapitalization: TextCapitalization.characters,
                        style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1.5),
                        onChanged: (val) {
                          _aramaMetni = val.toUpperCase();
                          textEditingController.value = textEditingController.value.copyWith(text: val.toUpperCase(), selection: TextSelection.collapsed(offset: val.length));
                        },
                        decoration: InputDecoration(
                          hintText: 'Kod veya Isim Gir...',
                          hintStyle: TextStyle(
                            // 🔥 withOpacity yerine withValues
                            color: Colors.blue.shade900.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.search,
                            size: 30,
                            color: Colors.blue.shade900,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_circle_right, size: 32),
                            color: Colors.blue.shade900,
                            onPressed: () {
                              if (textEditingController.text.isNotEmpty) {
                                analizEt(textEditingController.text.trim().toUpperCase());
                              }
                            },
                          ),
                        )
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _buildKategoriPaneli(0, "BIST Populer", Icons.trending_up, Colors.blue.shade700, _bist30, Colors.blue.shade50, Colors.blue.shade900),
              _buildKategoriPaneli(1, "ABD Devleri (50 Hisse)", Icons.flag, Colors.indigo.shade700, _abdHisseler, Colors.indigo.shade50, Colors.indigo.shade900),
              _buildKategoriPaneli(2, "Kripto Sepeti (50 Coin)", Icons.currency_bitcoin, Colors.orange.shade700, _kriptolar, Colors.orange.shade50, Colors.brown.shade900),
              _buildKategoriPaneli(3, "Emtia Sepeti (20 Emtia)", Icons.diamond, Colors.brown.shade700, _emtialar, Colors.amber.shade100, Colors.black87),
              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(height: 55, child: ElevatedButton(onPressed: _isLoading ? null : () {
                        if (_aramaMetni.isNotEmpty) {
                            analizEt(_aramaMetni);
                        } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lutfen bir kod yazin!")));
                        }
                    }, style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome), SizedBox(width: 10), Text('YAPAY ZEKA ILE ANALIZ ET', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))])))),
                ],
              ),

              const SizedBox(height: 15),

              SizedBox(height: 55, child: ElevatedButton(onPressed: (_isPortfolioLoading || _isLoading) ? null : _kategoriSecimPenceresi, style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5), child: _isPortfolioLoading ? const CircularProgressIndicator(color: Colors.white) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.rocket_launch), SizedBox(width: 10), Text('Gelecek K/Z Simulasyonlari', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]))),

              const SizedBox(height: 30),
              if (_errorMessage.isNotEmpty && !_isLoading) Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(10)), child: Text(_errorMessage, style: TextStyle(color: Colors.red.shade900), textAlign: TextAlign.center)),

              if (_analizTamamlandi && !_isLoading) ...[
                Card(
                  elevation: 8,
                  color: cardBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Center(child: Text("ANALIZ RAPORU", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: yaziRengi, letterSpacing: 1.2))),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            // 🔥 withOpacity yerine withValues
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: yaziRengi.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Tahmin Vadesi: ",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              DropdownButton<int>(
                                value: _secilenGun,
                                dropdownColor: Colors.white,
                                icon: Icon(Icons.arrow_drop_down, color: yaziRengi),
                                underline: Container(),
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text("1 Gün (Yarın)", style: TextStyle(color: Colors.black))),
                                  DropdownMenuItem(value: 3, child: Text("3 Gün", style: TextStyle(color: Colors.black))),
                                  DropdownMenuItem(value: 7, child: Text("1 Hafta", style: TextStyle(color: Colors.black))),
                                  DropdownMenuItem(value: 30, child: Text("1 Ay", style: TextStyle(color: Colors.black))),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    analizEt(_sembolKodu!, gun: val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(thickness: 2, color: yaziRengi.withValues(alpha: 0.5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _sembol!,
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: yaziRengi),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    // 🔥 withOpacity yerine withValues
                                    color: isPositive
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.red.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isPositive ? Colors.green : Colors.red),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(degisimIkonu, size: 16, color: degisimRengi),
                                      const SizedBox(width: 4),
                                      Text(
                                        "%$_degisimOrani",
                                        style: TextStyle(fontWeight: FontWeight.bold, color: degisimRengi),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // 🔥 withOpacity yerine withValues
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: yaziRengi, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Tarih / Saat :",
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _guncelZaman ?? "---",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(
            "Anlık Fiyat :",
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _guncelFiyat!,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
          ),
        ],
      ),
    ),
  ],
)

,
                        const SizedBox(height: 20),
                        Row(children: [Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: infoBoxColor, borderRadius: BorderRadius.circular(15)), child: Column(children: [_buildInfoRow(Icons.calendar_today, "Veri Tarihi:", _veriTarihi!, yaziRengi, yaziRengi, etiketRengi), _buildInfoRow(Icons.history, "Onceki Kapanis:", _oncekiKapanis!, yaziRengi, yaziRengi, etiketRengi)]))), const SizedBox(width: 15), Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: infoBoxColor, borderRadius: BorderRadius.circular(15)), child: Column(children: [_buildInfoRow(Icons.event_available, "Hedef Tarihi:", _hedefTarihi!, yaziRengi, yaziRengi, etiketRengi), _buildInfoRow(Icons.model_training, "Tahmini Fiyat:", _tahminFiyat!, yaziRengi, yaziRengi, etiketRengi)])))]),
                        const SizedBox(height: 20),
                        Container(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20), decoration: BoxDecoration(color: zeminRengi != Colors.white ? Colors.white : (isDarkMode ? Colors.grey.shade800 : Colors.white), borderRadius: BorderRadius.circular(15), border: Border.all(color: grafikRengi, width: 3)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Column(children: [Text("Fark", style: TextStyle(color: zeminRengi != Colors.white ? etiketRengi : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700))), Row(children: [Icon(_fark!.startsWith("-") ? Icons.trending_down : Icons.trending_up, color: _fark!.startsWith("-") ? Colors.red : Colors.green), const SizedBox(width: 5), Text("%$_fark", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: zeminRengi != Colors.white ? yaziRengi : (isDarkMode ? Colors.white : Colors.black87)))])]), Column(children: [Text("SINYAL", style: TextStyle(color: zeminRengi != Colors.white ? etiketRengi : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700))), Text(_sinyal!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: grafikRengi))])])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildGrafikKutusu(grafikRengi, zeminRengi, isDarkMode),
              ],
              const SizedBox(height: 50),
            ]))));
  }
}

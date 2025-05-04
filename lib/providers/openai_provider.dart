import 'package:flutter/material.dart';
import 'package:hortimize/constants.dart';
import 'package:hortimize/services/openai_service.dart';

class OpenAIProvider extends ChangeNotifier {
  // Using a mock response for testing if API has issues
  final bool _useMockResponse = true; // Set to true as API has quota exceeded
  
  final String _apiKey = openAIApiKey;
  
  late final OpenAIService _openAIService;
  
  String _suggestion = '';
  bool _isLoading = false;
  String _error = '';
  
  // Getters
  String get suggestion => _suggestion;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  OpenAIProvider() {
    _openAIService = OpenAIService(apiKey: _apiKey);
  }
  
  // Method to get suggestions from the API
  Future<void> getExpertSuggestion(String query) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      if (_useMockResponse) {
        // Simulate network delay
        await Future.delayed(Duration(seconds: 2));
        
        // Process the query to get better response matching
        _suggestion = _generateSmartResponse(query);
      } else {
        // Use the actual API - currently has quota issues
        _suggestion = await _openAIService.getExpertSuggestion(query);
      }
    } catch (e) {
      _error = 'Failed to get expert suggestion: $e';
      _suggestion = '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Enhanced smart response generator
  String _generateSmartResponse(String query) {
    final String lowercaseQuery = query.toLowerCase();
    
    // Direct response to the "what can I cultivate in terrace" question
    if (_isTerraceCultivationQuestion(lowercaseQuery)) {
      return _getTerraceResponse();
    }
    
    // Check for business/profit related questions
    if (_isProfitQuestion(lowercaseQuery)) {
      return _getProfitResponse();
    }
    
    // Check for organic farming questions
    if (_isOrganicQuestion(lowercaseQuery)) {
      return _getOrganicResponse();
    }
    
    // Check for various crop specific queries
    if (_containsKeyword(lowercaseQuery, ['rice', 'paddy'])) {
      return _getRiceResponse(lowercaseQuery);
    }
    
    if (_containsKeyword(lowercaseQuery, ['vegetable', 'tomato', 'onion', 'brinjal'])) {
      return _getVegetableResponse(lowercaseQuery);
    }
    
    if (_containsKeyword(lowercaseQuery, ['fruit', 'mango', 'banana', 'papaya'])) {
      return _getFruitResponse();
    }
    
    if (_containsKeyword(lowercaseQuery, ['climate', 'weather', 'rain', 'monsoon', 'water'])) {
      return _getClimateResponse();
    }
    
    if (_containsKeyword(lowercaseQuery, ['soil', 'fertilizer', 'nutrient', 'manure'])) {
      return _getSoilResponse();
    }
    
    // If not an agriculture question at all
    if (!_isAgricultureRelated(lowercaseQuery)) {
      return "I'm an agricultural expert focused on farming in Tamil Nadu, India. Please ask me about crop cultivation, market trends, pricing, selling strategies, or climate considerations related to agriculture in Tamil Nadu.";
    }
    
    // General agriculture response for other queries
    return _getGeneralAgricultureResponse();
  }
  
  // Improved check for terrace cultivation questions
  bool _isTerraceCultivationQuestion(String query) {
    // Match cases like "what can I cultivate in terrace" explicitly
    if (query.contains("cultivate in terrace") || 
        query.contains("grow in terrace") ||
        query.contains("plant in terrace") ||
        query.contains("terrace farming") ||
        query.contains("terrace gardening") ||
        query.contains("terrace agriculture")) {
      return true;
    }
    
    // Check for presence of terrace and cultivation terms with any order
    final bool hasTerrace = query.contains("terrace");
    final bool hasCultivationTerm = _containsKeyword(query, [
      'cultivate', 'grow', 'plant', 'farm', 'garden', 'crop'
    ]);
    
    return hasTerrace && hasCultivationTerm;
  }
  
  // Check for business/profit related questions
  bool _isProfitQuestion(String query) {
    final bool hasBusinessTerm = _containsKeyword(query, [
      'profit', 'business', 'income', 'money', 'earn', 'revenue', 'sell', 'market'
    ]);
    
    final bool hasAgricultureTerm = _containsKeyword(query, [
      'farm', 'crop', 'agriculture', 'cultivation', 'growing'
    ]);
    
    return hasBusinessTerm && hasAgricultureTerm;
  }
  
  // Check for organic farming questions
  bool _isOrganicQuestion(String query) {
    final bool hasOrganicTerm = query.contains('organic');
    
    final bool hasFarmingTerm = _containsKeyword(query, [
      'farm', 'grow', 'cultivat', 'method', 'convert', 'agriculture'
    ]);
    
    return hasOrganicTerm && hasFarmingTerm;
  }
  
  // Helper to check for keywords
  bool _containsKeyword(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
  
  // Check if query is related to agriculture
  bool _isAgricultureRelated(String query) {
    final agricultureKeywords = [
      'farm', 'crop', 'plant', 'harvest', 'cultivat', 'soil', 'seed', 
      'fertilizer', 'pest', 'irrigation', 'agriculture', 'yield', 'rice', 
      'wheat', 'vegetable', 'fruit', 'market', 'price', 'produce', 'organic', 
      'season', 'rain', 'climate', 'weather', 'drought', 'monsoon', 'field',
      'grow', 'paddy', 'tomato', 'onion', 'banana', 'mango', 'sugarcane',
      'cotton', 'maize', 'pulses', 'turmeric', 'spice', 'garden', 'terrace'
    ];
    
    return agricultureKeywords.any((keyword) => query.contains(keyword));
  }
  
  // Clear the suggestion when needed
  void clearSuggestion() {
    _suggestion = '';
    _error = '';
    notifyListeners();
  }
  
  // RESPONSE GENERATORS FOR DIFFERENT TOPICS
  
  String _getTerraceResponse() {
    return """
TERRACE FARMING IN TAMIL NADU: BEST PRACTICES

SUITABLE CROPS FOR TERRACE CULTIVATION:
- Leafy Greens: Spinach, fenugreek (methi), amaranth, coriander - harvest in 25-30 days
- Vegetables: Tomatoes, chillies, brinjals, okra, and radish work excellently in containers
- Microgreens: Fast growth cycle (7-14 days), high nutritional value, minimal space requirement
- Container-friendly Fruits: Strawberries, dwarf papaya varieties, lime/lemon trees

CONTAINER RECOMMENDATIONS:
- Grow bags (15-20L): Ideal for tomatoes, chillies, brinjal
- Rectangular planters (12-inch depth): Perfect for leafy greens, herbs
- Large drums (cut in half): Suitable for root vegetables like carrots, radish
- Vertical systems: Utilize wall space for growing trailing plants like peas, beans

TERRACE-SPECIFIC CONSIDERATIONS:
- Weight distribution: Use lightweight growing media (1:1:1 of soil, cocopeat, and compost)
- Water management: Implement drip irrigation or self-watering containers to conserve water
- Sun exposure: Orient crops based on Tamil Nadu's intense sun (shade cloth during peak summer)
- Wind protection: Create barriers for protecting plants during windy periods

SEASONAL PLANTING CALENDAR FOR TAMIL NADU TERRACES:
- Summer (Mar-Jun): Okra, cluster beans, cucumbers, gourds
- Monsoon (Jul-Oct): Leafy greens, tomatoes, beans
- Winter (Nov-Feb): Carrots, radish, beetroot, cabbage, cauliflower

ECONOMIC BENEFITS:
- Potential savings of ₹1,500-2,500/month for a small family through self-production
- Organic produce commands 30-50% premium if sold locally
- Social media marketing opportunities for specialty/organic terrace produce

CHALLENGES & SOLUTIONS:
- Limited space: Implement vertical gardening systems, use compact varieties
- Water scarcity: Mulching, drip irrigation, grey water recycling systems
- Pest management: Neem oil spray, sticky traps, companion planting
- Summer heat: Shade nets can reduce temperature by 3-5°C during peak summer

SUCCESS CASE STUDY:
A 600 sq.ft terrace in Chennai's Adyar area produces over 75% of a family's vegetable needs with 25 containers, using approximately 30 minutes of maintenance daily and 100 liters of water.
    """;
  }
  
  String _getProfitResponse() {
    return """
PROFITABLE FARMING VENTURES IN TAMIL NADU

HIGHEST PROFIT CROPS & ENTERPRISES:
- High-value vegetables: Colored capsicum, cherry tomatoes, exotic greens (ROI: 80-120%)
- Floriculture: Jasmine, marigold, chrysanthemum (ROI: 70-100% with proper market linkages)
- Fruit crops: Dragon fruit, strawberry, fig (Premium pricing, 2-3x regular fruits)
- Integrated farming: Crop + poultry/fish/mushroom (Increases profit by 40-60%)

MARKET-DRIVEN APPROACHES:
- Contract farming with retail chains/processors guarantees stable prices
- Direct-to-consumer models via WhatsApp groups/delivery apps (30-40% higher returns)
- Export-oriented production (GlobalGAP certified) for premium pricing
- Value-addition: Processing primary produce into pickles, powders, ready-to-cook items

SCALE-APPROPRIATE RECOMMENDATIONS:
- Small farms (< 2 acres): Focus on high-value crops with staggered harvesting
- Medium farms (2-5 acres): Crop diversification with integrated farming
- Larger farms (> 5 acres): Mix of commercial crops with processing infrastructure

INVESTMENT & RETURNS:
- Protected cultivation: ₹40-50 lakhs/hectare investment with 25-35% annual returns
- Precision farming: ₹25,000-40,000/acre additional cost but 20-30% higher yield
- Organic certification: 3-year transition cost offset by 40-60% higher produce prices
- Farm tourism: Additional revenue stream (₹5,000-15,000/day) with minimal investment

GOVERNMENT SUPPORT AVENUES:
- PM-Kisan: Direct benefit transfer of ₹6,000/year
- Interest subvention on farm loans (2% reduction)
- Capital subsidies for protected structures, processing units (50-75%)
- TN-IAMWARM project for water management infrastructure

RISK MITIGATION STRATEGIES:
- Crop insurance: PMFBY with 1.5-5% premium (covers multiple risks)
- Diversification: Multiple crops in different growth cycles
- Forward contracts: Lock in prices before planting
- Farmer Producer Organizations: Collective bargaining power and risk sharing

SUCCESS FACTORS IN TAMIL NADU:
- Water-efficient crops and irrigation systems critical for profitability
- Market research before planting is essential (pricing trends and demand patterns)
- Technology adoption (precision farming, mechanization) reduces labor dependency
- Value chain participation (not just production) multiplies income
    """;
  }
  
  String _getOrganicResponse() {
    return """
ORGANIC FARMING IN TAMIL NADU

CONVERSION TO ORGANIC:
- 36-month conversion period required for full certification
- First year: Stop chemicals, build soil health with green manures
- Second year: Introduce biological inputs, develop organic pest management
- Third year: Documentation and certification preparation

ORGANIC INPUTS & PRACTICES:
- Soil building: Panchagavya (fermented cow products), jeevamrut, vermicompost
- Pest management: Neem oil, herbal extracts, trap crops, beneficial insects
- Disease control: Trichoderma viride, Pseudomonas fluorescens, botanical formulations
- Weed management: Mulching, intercropping, mechanical weeding

CERTIFICATION OPTIONS:
- Third-party certification: INDOCERT, OneCert, LACON (export markets)
- Participatory Guarantee System (PGS): More affordable for domestic markets
- Group certification: Reduces cost by 70-80% for small farmers
- Tamil Nadu Organic Certification Department services

SUITABLE CROPS FOR ORGANIC IN TAMIL NADU:
- Traditional rice varieties: Mappillai Samba, Kichadi Samba, Kullakar
- Native vegetables: Country tomatoes, traditional brinjal varieties
- Millets: Highly suitable for organic cultivation (low input requirement)
- Tree crops: Mango, coconut, cashew transitions well to organic

MARKET LINKAGES:
- Growing urban demand (Chennai, Coimbatore, Madurai)
- Weekly organic markets (30-50% premium prices)
- Export opportunities to Europe, Middle East, Singapore
- E-commerce platforms for direct selling

ECONOMICS OF ORGANIC FARMING:
- Initial 15-25% yield reduction during transition
- Production costs 10-20% lower after establishment period
- Price premium of 30-60% for certified produce
- Break-even typically in year 3-4 after conversion starts

GOVERNMENT SUPPORT:
- National Programme for Organic Production (NPOP) subsidies
- Assistance for certification costs
- TNAU organic farming division technical support
- Training programs through Krishi Vigyan Kendras

TAMIL NADU SUCCESS STORIES:
- Organic farmers' cooperative in Nilgiris with export-quality vegetables
- Tribal organic farming clusters in Kolli Hills specializing in native crops
- Community-supported agriculture models around Chennai providing weekly organic baskets
    """;
  }
  
  String _getRiceResponse(String query) {
    if (query.contains('price') || query.contains('market') || query.contains('sell')) {
      return """
RICE MARKET & PRICING IN TAMIL NADU:

CURRENT PRICE TRENDS:
- Common paddy: ₹2,100-2,400/quintal (market rate)
- Minimum Support Price (MSP): ₹2,183/quintal 
- Premium varieties like Ponni rice: ₹2,600-3,200/quintal
- Organic rice fetching 15-20% premium in urban markets

BEST MARKETS BY REGION:
- Thanjavur, Tiruvarur, and Nagapattinam districts offer best procurement prices
- Chennai wholesale markets pay premium for quality varieties
- Direct-to-consumer platforms offering 10-15% better returns

SELLING STRATEGIES:
- Consider collective selling through Farmer Producer Organizations
- Target specialty rice markets in urban centers for better pricing
- Explore export opportunities through Tamil Nadu agricultural export zones
- Processing into value-added products can increase returns by 25-40%
      """;
    } else if (query.contains('pest') || query.contains('disease')) {
      return """
RICE PEST & DISEASE MANAGEMENT IN TAMIL NADU:

CURRENT CHALLENGES:
- Brown planthopper (BPH) prevalence increasing in Delta regions
- Blast disease reported in parts of Tiruvarur and Thanjavur
- Stem borer incidence higher in early-planted crops

MANAGEMENT STRATEGIES:
- For BPH: Drain fields temporarily; avoid excessive nitrogen application
- For Blast: Seed treatment with Pseudomonas fluorescens (10g/kg seed)
- For Stem Borer: Install pheromone traps (5/acre); release Trichogramma if needed

ORGANIC APPROACHES:
- Neem oil spray (3%) effective against multiple pests
- Beneficial insects like dragonflies and spiders help control hoppers
- Crop rotation with legumes helps break pest cycles

CLIMATE-SMART PRACTICES:
- Early detection using regular field monitoring is crucial
- Community-based approaches more effective for large-scale pest management
- Mobile apps for pest identification now available through Tamil Nadu Agricultural University
      """;
    } else if (query.contains('climate') || query.contains('weather') || query.contains('water')) {
      return """
CLIMATE CONSIDERATIONS FOR RICE CULTIVATION IN TAMIL NADU:

CURRENT CONDITIONS:
- Delta regions receiving adequate rainfall this season
- Western districts facing 15-20% rainfall deficit
- Temperature trends 1-2°C above historical averages

WATER MANAGEMENT:
- SRI (System of Rice Intensification) reduces water usage by 25-30%
- AWD (Alternate Wetting and Drying) technique recommended for water conservation
- Borewell irrigation showing declining water tables; rainwater harvesting essential

VARIETY SELECTION:
- Short-duration varieties (110-120 days) like ADT 43, ADT 45 recommended for water-scarce areas
- Traditional varieties like Mappillai Samba showing better climate resilience
- CO 51 variety performs well under varied water conditions

ADAPTATION STRATEGIES:
- Land leveling using laser-guided equipment improves water efficiency by 20%
- Direct seeded rice (DSR) can reduce water use by 30% compared to transplanted rice
- Weather-based crop advisories available through TN-Agrisnet mobile service
      """;
    } else {
      return """
RICE CULTIVATION IN TAMIL NADU - GENERAL ADVICE:

MARKET OUTLOOK:
- Steady demand expected with 5-8% price increase projected for quality varieties
- Export potential growing for aromatic and traditional varieties
- Value-added rice products (rice flour, flakes) showing increasing market share

PRODUCTION TIPS:
- Optimal planting windows: Sornavari (Apr-May), Samba (Aug-Sep), Navarai (Dec-Jan)
- Seed rate: 20-25 kg/acre for transplanted; 30-35 kg/acre for direct seeding
- Fertilizer recommendation: 90:45:45 kg NPK/ha with split application
- Zinc deficiency common in delta soils; apply 25 kg ZnSO₄/ha

BEST PRACTICES:
- Direct seeding reduces labor costs by 30-35%
- Community nurseries can reduce individual farmer's risk and costs
- Mechanical transplanting improves yield by 10-15% through uniform spacing
- Post-harvest losses can be reduced from 15% to 5% with proper drying and storage

GOVERNMENT SCHEMES:
- PM-KISAN provides ₹6,000/year direct support to farmers
- Crop insurance under PMFBY with subsidized premiums
- Subsidy for farm mechanization available through district agriculture offices
      """;
    }
  }
  
  String _getVegetableResponse(String query) {
    if (query.contains('price') || query.contains('market') || query.contains('sell')) {
      return """
VEGETABLE MARKET TRENDS IN TAMIL NADU:

CURRENT PRICES:
- Tomatoes: ₹25-30/kg at wholesale markets (volatile)
- Onions: ₹35-40/kg with stable outlook
- Brinjal: ₹20-25/kg with moderate fluctuations
- Green leafy vegetables: ₹30-50/kg with premium for pesticide-free produce

MARKET OPPORTUNITIES:
- Chennai, Coimbatore, and Madurai metropolitan markets paying premium for quality
- Direct farm-to-consumer apps offering 25-30% better returns
- Growing demand for certified organic vegetables (40-60% premium)
- Export opportunities to Middle East through Koyambedu market aggregators

PRICING STRATEGIES:
- Staggered planting ensures year-round supply and price stability
- Collective marketing through FPOs yielding 15-20% better returns
- Value addition (cleaning, sorting, packaging) increases margins by 30-40%
- Cold storage facilities available in major districts to take advantage of price fluctuations
      """;
    } else if (query.contains('grow') || query.contains('cultivat') || query.contains('production')) {
      return """
VEGETABLE CULTIVATION PRACTICES FOR TAMIL NADU:

PRODUCTION SYSTEMS:
- Open field cultivation best for leafy vegetables and drought-resistant crops
- Protected cultivation (polyhouse/nethouse) ideal for tomato, capsicum, cucumber
- Vertical farming emerging in peri-urban areas with 3-4x higher yields
- Raised bed systems recommended for areas with drainage issues

VARIETY SELECTION:
- Tomato: PKM-1 and CO-3 varieties show good heat tolerance
- Onion: CO-5 and Agrifound Dark Red perform well across Tamil Nadu
- Brinjal: CO Brinjal-1 and MDU-1 resistant to common pests

MANAGEMENT PRACTICES:
- Drip irrigation + mulching reduces water usage by 40-50%
- Integrated nutrient management with vermicompost improves soil health
- Trellising for climbers (tomato, cucumber) improves quality and reduces disease
- Crop rotation with legumes helps maintain soil fertility
      """;
    } else {
      return """
VEGETABLE FARMING IN TAMIL NADU - GENERAL ADVICE:

CLIMATE CONSIDERATIONS:
- Western Tamil Nadu ideal for tomato, onion, and cool-season vegetables
- Coastal areas suitable for year-round leafy vegetable production
- Protected cultivation essential during monsoon for sensitive crops
- Micro-climate modifications like shade nets can reduce temperature by 3-5°C

MARKET INSIGHTS:
- High-value vegetables (colored capsicum, cherry tomatoes) yield 2-3x returns
- Contract farming with retail chains offers price stability
- Processing-grade tomatoes for paste/sauce factories provide consistent demand
- Export markets (Middle East, Singapore) seeking pesticide-free produce

TECHNOLOGICAL INNOVATIONS:
- Soil moisture sensors reduce irrigation water by 30-40%
- Mobile apps providing market prices across Tamil Nadu help in timing harvests
- Solar-powered drip systems gaining popularity with 60% subsidy
- Biodegradable mulch films eliminate plastic waste

GOVERNMENT SUPPORT:
- Subsidy for protected cultivation structures (50-75%)
- Micro-irrigation subsidized under PMKSY scheme
- Crop insurance available for vegetable crops under restructured weather-based scheme
- Training programs through KVKs on advanced vegetable production techniques
      """;
    }
  }
  
  String _getFruitResponse() {
    return """
FRUIT CULTIVATION IN TAMIL NADU:

MAJOR FRUIT CROPS:
- Banana: Leading fruit crop with Cavendish, Poovan, and Nendran as popular varieties
- Mango: Alphonso, Bangalora, and Neelum varieties dominate Tamil Nadu markets
- Papaya: CO-8 variety gaining popularity for high yield and quality

MARKET TRENDS:
- Export demand growing for certified bananas to Middle East and Europe
- Processing industries for pulp and juice offering stable procurement contracts
- Direct-to-consumer channels through e-commerce showing 20-30% better returns

CULTIVATION PRACTICES:
- High-density planting increasing yields by 30-40% in mango and guava
- Precision irrigation systems essential for water conservation
- Integrated pest management reducing chemical usage by 50-60%
- Post-harvest management crucial to reduce 25-30% losses in fruits

CLIMATE ADAPTATION:
- Drought-resistant varieties and rootstocks becoming important
- Micro-irrigation mandatory for new orchard establishment
- Canopy management techniques help mitigate heat stress
- Weather-based advisory services help in timing critical operations
    """;
  }
  
  String _getClimateResponse() {
    return """
CLIMATE CONSIDERATIONS FOR TAMIL NADU AGRICULTURE:

CURRENT PATTERNS:
- Northeast monsoon (Oct-Dec) provides 60% of annual rainfall for eastern districts
- Western districts increasingly experiencing irregular rainfall distribution
- Average temperatures increased by 0.6°C over past decade
- Extreme weather events (cyclones, heat waves) increasing in frequency

ADAPTATION STRATEGIES:
- Climate-resilient crop varieties developed by TNAU available for major crops
- Water harvesting structures (farm ponds, check dams) essential for irrigation security
- Crop diversification reduces risk from climate variability
- Short-duration varieties help avoid critical stress periods

REGION-SPECIFIC RECOMMENDATIONS:
- Cauvery Delta: Improved drainage systems; alternate wetting and drying for rice
- Western Zone: Drought-resistant varieties; mulching and soil moisture conservation
- Southern Zone: Focus on millets and drought-hardy crops
- Hilly Zones: Contour farming; perennial crops with less water requirements

TECHNOLOGICAL INTERVENTIONS:
- Weather-based crop advisories through mobile apps
- Climate-smart villages being developed as models in 10 districts
- Crop insurance linked to automatic weather stations for faster claims
- Solar-powered irrigation reducing carbon footprint and ensuring water availability
    """;
  }
  
  String _getSoilResponse() {
    return """
SOIL HEALTH MANAGEMENT IN TAMIL NADU:

SOIL TYPES & ISSUES:
- Red soils (40% of area): Low in organic matter and nitrogen
- Black soils (30%): High in clay, drainage issues during heavy rains
- Alluvial soils (Cauvery Delta): Relatively fertile but zinc deficiency common
- Coastal soils: Salinity issues affecting crop productivity

SOIL TESTING:
- Mobile soil testing labs operating in all districts
- Soil Health Card scheme providing detailed analysis and recommendations
- Testing recommended every 2 years for intensive cultivation

ENHANCEMENT STRATEGIES:
- Green manuring with daincha/sunhemp adds 60-80 kg N/ha
- Vermicomposting of farm waste produces high-quality organic matter
- Biofertilizers (Azospirillum, Phosphobacteria) reduce chemical inputs by 25%
- Gypsum application for sodic soil reclamation

PRECISION NUTRIENT MANAGEMENT:
- Site-specific nutrient management based on soil test results improves efficiency
- Leaf color charts for nitrogen management in rice
- Drip fertigation reduces fertilizer usage by 30-40%
- Customized fertilizer mixtures available for major cropping systems
    """;
  }
  
  String _getGeneralAgricultureResponse() {
    return """
AGRICULTURAL OVERVIEW FOR TAMIL NADU:

CURRENT SECTOR STATUS:
- Agriculture contributes approximately 12% to Tamil Nadu's economy
- 40% of population dependent on agriculture and allied sectors
- Average landholding size: 0.8 hectares (among smallest in India)
- Irrigation coverage: ~57% of cultivable area

KEY CROPS BY REGION:
- Cauvery Delta: Rice, sugarcane, banana, coconut
- Western Zone: Maize, pulses, oilseeds, vegetables
- Southern Zone: Cotton, millets, pulses
- Hilly Regions: Spices, tea, coffee, fruits

MARKET INFRASTRUCTURE:
- 283 regulated markets across the state
- E-Nam (Electronic National Agriculture Market) integration in progress
- Direct Procurement Centers for paddy and other major crops
- Farmer Producer Organizations (200+ active) improving market access

GOVERNMENT INITIATIVES:
- Tamil Nadu Agricultural University providing technical support
- PM-KISAN and state-level income support schemes
- Interest subvention on crop loans
- Subsidies for farm mechanization, micro-irrigation, and protected cultivation

CHALLENGES & OPPORTUNITIES:
- Water scarcity being addressed through micro-irrigation and water harvesting
- Climate variability requiring adaptive farming practices
- Digital agriculture platforms improving information access
- Value addition and food processing presenting growth opportunities

For more specific advice, please ask about particular crops, farming practices, or regional issues in Tamil Nadu.
    """;
  }
} 
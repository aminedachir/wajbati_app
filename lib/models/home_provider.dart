import 'package:flutter/foundation.dart';
import '../utils/appwrite_service.dart';
import 'models.dart';
import 'algerian_wilayas.dart';

class HomeProvider extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String _selectedType = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedWilaya = defaultWilaya;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String get selectedType => _selectedType;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedWilaya => _selectedWilaya;

  HomeProvider() {
    fetchRestaurants();
  }

  List<Restaurant> get homeCooks =>
      _restaurants.where((r) => r.isHomeCook).toList();

  List<Restaurant> get healthFriendlyRestaurants => _restaurants.where((r) {
        return r.type != 'Patisserie' &&
            (r.category.contains('Health') ||
                r.menu.any((item) =>
                    item.isDiabeticFriendly || item.isHealthOriented));
      }).toList();

  List<Restaurant> get popularRestaurants =>
      _restaurants.where((r) => r.rating >= 4.5).toList();

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    notifyListeners();
    try {
      final docs = await AppwriteService.getRestaurants();
      final fetched = docs
          .map((doc) => Restaurant.fromAppwrite(doc.data, doc.$id))
          .toList();

      // Inject demo data for Home Cooking and Videos
      _restaurants = [
        ...fetched,
        const Restaurant(
          id: 'demo_video_1',
          name: 'Tommy Burger',
          nameAr: 'تومي برجر',
          category: 'أكل سريع',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1571091718767-18b5b1457add?q=80&w=2072',
          rating: 4.8,
          reviewCount: 350,
          deliveryTime: '15-25 دقيقة',
          deliveryFee: 100,
          isOpen: true,
          address: 'قسنطينة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778350839/AQMKTSR0m-LeJSl4jCqot-UsEfCTiI2Pxt1cPqATgdsc2vSSpioTUAxDChWQSUAR0IW9x5edZrzvqpA7qWHOY42Y0zJmD6cNsa65FPtduA_whpp5u.mp4',
        ),
        const Restaurant(
          id: 'demo_video_3',
          name: 'Tommy Burger Special',
          nameAr: 'تومي برجر - عرض خاص',
          category: 'أكل سريع',
          type: 'Fast Food',
          imageUrl:
              'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=2000',
          rating: 4.9,
          reviewCount: 120,
          deliveryTime: '15-25 دقيقة',
          deliveryFee: 100,
          isOpen: true,
          address: 'قسنطينة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778350801/AQPag-QHQoxHAMfPLw0YyW7FBe1JUiHkjOR-UgJ-VX_eL0YoEaL5xbBaKxULiLqHDpaTZaX_H96cQ8F4cXZ36_QkfpHdbGGGipkj_Ug_me1nxh.mp4',
        ),
        const Restaurant(
          id: 'demo_video_4',
          name: 'ARYQA Food Addict',
          nameAr: 'أريقة - مدمن طعام',
          category: 'وجبات منوعة',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070',
          rating: 4.7,
          reviewCount: 180,
          deliveryTime: '20-30 دقيقة',
          deliveryFee: 150,
          isOpen: true,
          address: 'الجزائر',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778352084/AQPudyt3n3rlUEPy_Ov5QKqj4pFc8SU8TGbK8zRG_cA-lFBP0vCijRwM5_DbvJlvsOVGa9CZuxcvTO_igt6PiVQ-BKji08fbGjxiWP-pI-4IpQ_k6v33k.mp4',
        ),
        const Restaurant(
          id: 'demo_video_5',
          name: 'ARYQA Food Addict 2',
          nameAr: 'أريقة - وجبات مميزة',
          category: 'وجبات منوعة',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=2069',
          rating: 4.8,
          reviewCount: 95,
          deliveryTime: '20-30 دقيقة',
          deliveryFee: 150,
          isOpen: true,
          address: 'الجزائر',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778352030/AQPtrbChkF1fPHGw9iamVGGX6rkn0q452twSU2261jo1sT-FK_9VLP-W0O4BDUE7QhTOtZHQ9bTgP7jDVYMHYaLH_fAd0g-wNyLpLQ4_dkyk3g.mp4',
        ),
        const Restaurant(
          id: 'demo_video_6',
          name: 'Savannah',
          nameAr: 'سافانا',
          category: 'وجبات فاخرة',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=2070',
          rating: 4.9,
          reviewCount: 420,
          deliveryTime: '25-35 دقيقة',
          deliveryFee: 200,
          isOpen: true,
          address: 'وهران',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778352815/AQMQK2Q2A5UG3BBmuVjF6wqXiX5bBJYBqa78J3s6CRG3DlAD1pX3gI2zcEyEgmlAmmwRL9tOrUVMEuHPgqTji-j_jsm9_L-w48guQlI_xhfew7.mp4',
        ),
        const Restaurant(
          id: 'demo_video_7',
          name: 'Savannah Lounge',
          nameAr: 'سافانا لاونج',
          category: 'وجبات فاخرة',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1559339352-11d035aa65de?q=80&w=2074',
          rating: 4.9,
          reviewCount: 150,
          deliveryTime: '25-35 دقيقة',
          deliveryFee: 200,
          isOpen: true,
          address: 'وهران',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778352738/AQPgYpJXBtt5WtOSrv1IYDQRBSCC6yVpG2yFV64-wewwg3pQeJSJZwPZSJvKqHfzwOQArKn5FAx8xl7N6WPJYNgTImIt94cwq8ga-QqmWA_1_hx65m1.mp4',
        ),
        const Restaurant(
          id: 'demo_video_8',
          name: 'Woody One',
          nameAr: 'وودي ون',
          category: 'مشويات وبرجر',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=2074',
          rating: 4.8,
          reviewCount: 210,
          deliveryTime: '20-30 دقيقة',
          deliveryFee: 150,
          isOpen: true,
          address: 'الجزائر العاصمة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353015/AQM3dkf8W3Fb9u8fHO-Oe_c7NpSBC4YNSzkRWu7sspRG45VV1WczKh63AoEz0nsBlDXXBgTccpdQUOr8KDgAevz3utZvTOOG5AqrtnGSbw_r0xtns.mp4',
        ),
        const Restaurant(
          id: 'demo_video_9',
          name: 'Woody One Steak',
          nameAr: 'وودي ون - ستيك',
          category: 'مشويات وبرجر',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=2069',
          rating: 4.9,
          reviewCount: 135,
          deliveryTime: '25-35 دقيقة',
          deliveryFee: 150,
          isOpen: true,
          address: 'الجزائر العاصمة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353060/AQNCKCdeIWaPm8tWV2rFeWTlzmKFjIUh4-bvZP6ywcHVxovJqvNNP8XwBq79ottWDasw2An6WpWdE_tZZM29MLSpas4Mo2wK-UVSQihv_Q_kn4ftc.mp4',
        ),
        const Restaurant(
          id: 'demo_video_10',
          name: 'Dream Restaurant',
          nameAr: 'مطعم الأحلام',
          category: 'أكل سريع',
          type: 'Fast Food',
          imageUrl:
              'https://images.unsplash.com/photo-1512152272829-e3139592d56f?q=80&w=2070',
          rating: 4.7,
          reviewCount: 310,
          deliveryTime: '15-25 دقيقة',
          deliveryFee: 100,
          isOpen: true,
          address: 'بجاية',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353213/AQPPvbaGpzLuwRVadCHpKEwwox9tSGB8PTfZYCe3JBFaoyQZCQnetUngzo7Ufa902YrMI8WWEORofp2NyB7NoQxROp486mKPXFY7doA_q8mkrd.mp4',
        ),
        const Restaurant(
          id: 'demo_video_11',
          name: 'Dream Fast Food',
          nameAr: 'دريم - أكل سريع',
          category: 'أكل سريع',
          type: 'Fast Food',
          imageUrl:
              'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?q=80&w=2071',
          rating: 4.8,
          reviewCount: 190,
          deliveryTime: '15-25 دقيقة',
          deliveryFee: 100,
          isOpen: true,
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353241/AQOcEdyJtrTN3B8Kfaul8GOaIeFyxHm8X2cpXWaHyz5hWN1KX3AFqo1D_ZDm0DIPdMtLwmeUQ-AwUOeR3bFllYRDfH6Wn2EP_dWSu1I_upwd0t.mp4',
          address: '',
        ),
        const Restaurant(
          id: 'demo_video_12',
          name: 'Mardoum Khemis Miliana',
          nameAr: 'مردوم خميس مليانة',
          category: 'تقليدي ومشاوي',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1544124499-58912cbddaad?q=80&w=2070',
          rating: 4.9,
          reviewCount: 520,
          deliveryTime: '30-45 دقيقة',
          deliveryFee: 250,
          isOpen: true,
          address: 'خميس مليانة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353370/AQNgGkIBGrbb9CAQSZJK_Ng5426RUg4LWR3AwjHiQGD-DI_EYYkUrHHWBNLPC5g1e-xbYEy5r3JSky9W6QvY8dIEriBi9YtRG6y85vMJ62wpLg_oaz1rv.mp4',
        ),
        const Restaurant(
          id: 'demo_video_13',
          name: 'Mardoum Special',
          nameAr: 'مردوم - عرض مميز',
          category: 'تقليدي ومشاوي',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1560614382-3334f797b8d4?q=80&w=2070',
          rating: 4.9,
          reviewCount: 215,
          deliveryTime: '30-45 دقيقة',
          deliveryFee: 250,
          isOpen: true,
          address: 'خميس مليانة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353375/AQNm80lqthqqpU6mEs0syzVm3L8gXX0RCtl_5mSM-RlTiQd12aMWLu2DK_YW62PcnYRAnbgIpWoYUi6si0KPl5NPbYMjuU0gYYBNdDR1H9eiAw_zgyzvq.mp4',
        ),
      ];
    } catch (e) {
      debugPrint('Fetch restaurants error: $e');
      _restaurants = [
        const Restaurant(
          id: 'demo_video_1',
          name: 'Tommy Burger',
          nameAr: 'تومي برجر',
          category: 'أكل سريع',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1571091718767-18b5b1457add?q=80&w=2072',
          rating: 4.8,
          reviewCount: 350,
          deliveryTime: '15-25 دقيقة',
          deliveryFee: 100,
          isOpen: true,
          address: 'قسنطينة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778350839/AQMKTSR0m-LeJSl4jCqot-UsEfCTiI2Pxt1cPqATgdsc2vSSpioTUAxDChWQSUAR0IW9x5edZrzvqpA7qWHOY42Y0zJmD6cNsa65FPtduA_whpp5u.mp4',
        ),
        const Restaurant(
          id: 'demo_video_3',
          name: 'Tommy Burger Special',
          nameAr: 'تومي برجر - عرض خاص',
          category: 'أكل سريع',
          type: 'Fast Food',
          imageUrl:
              'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=2000',
          rating: 4.9,
          reviewCount: 120,
          deliveryTime: '15-25 دقيقة',
          deliveryFee: 100,
          isOpen: true,
          address: 'قسنطينة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778350801/AQPag-QHQoxHAMfPLw0YyW7FBe1JUiHkjOR-UgJ-VX_eL0YoEaL5xbBaKxULiLqHDpaTZaX_H96cQ8F4cXZ36_QkfpHdbGGGipkj_Ug_me1nxh.mp4',
        ),
        const Restaurant(
          id: 'demo_video_4',
          name: 'ARYQA Food Addict',
          nameAr: 'أريقة - مدمن طعام',
          category: 'وجبات منوعة',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070',
          rating: 4.7,
          reviewCount: 180,
          deliveryTime: '20-30 دقيقة',
          deliveryFee: 150,
          isOpen: true,
          address: 'الجزائر',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778352084/AQPudyt3n3rlUEPy_Ov5QKqj4pFc8SU8TGbK8zRG_cA-lFBP0vCijRwM5_DbvJlvsOVGa9CZuxcvTO_igt6PiVQ-BKji08fbGjxiWP-pI-4IpQ_k6v33k.mp4',
        ),
        const Restaurant(
          id: 'demo_video_5',
          name: 'ARYQA Food Addict 2',
          nameAr: 'أريقة - وجبات مميزة',
          category: 'وجبات منوعة',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=2069',
          rating: 4.8,
          reviewCount: 95,
          deliveryTime: '20-30 دقيقة',
          deliveryFee: 150,
          isOpen: true,
          address: 'الجزائر',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778352030/AQPtrbChkF1fPHGw9iamVGGX6rkn0q452twSU2261jo1sT-FK_9VLP-W0O4BDUE7QhTOtZHQ9bTgP7jDVYMHYaLH_fAd0g-wNyLpLQ4_dkyk3g.mp4',
        ),
        const Restaurant(
          id: 'demo_video_6',
          name: 'Savannah',
          nameAr: 'سافانا',
          category: 'وجبات فاخرة',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=2070',
          rating: 4.9,
          reviewCount: 420,
          deliveryTime: '25-35 دقيقة',
          deliveryFee: 200,
          isOpen: true,
          address: 'وهران',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778352815/AQMQK2Q2A5UG3BBmuVjF6wqXiX5bBJYBqa78J3s6CRG3DlAD1pX3gI2zcEyEgmlAmmwRL9tOrUVMEuHPgqTji-j_jsm9_L-w48guQlI_xhfew7.mp4',
        ),
        const Restaurant(
          id: 'demo_video_7',
          name: 'Savannah Lounge',
          nameAr: 'سافانا لاونج',
          category: 'وجبات فاخرة',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1559339352-11d035aa65de?q=80&w=2074',
          rating: 4.9,
          reviewCount: 150,
          deliveryTime: '25-35 دقيقة',
          deliveryFee: 200,
          isOpen: true,
          address: 'وهران',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778352738/AQPgYpJXBtt5WtOSrv1IYDQRBSCC6yVpG2yFV64-wewwg3pQeJSJZwPZSJvKqHfzwOQArKn5FAx8xl7N6WPJYNgTImIt94cwq8ga-QqmWA_1_hx65m1.mp4',
        ),
        const Restaurant(
          id: 'demo_video_8',
          name: 'Woody One',
          nameAr: 'وودي ون',
          category: 'مشويات وبرجر',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=2074',
          rating: 4.8,
          reviewCount: 210,
          deliveryTime: '20-30 دقيقة',
          deliveryFee: 150,
          isOpen: true,
          address: 'الجزائر العاصمة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353015/AQM3dkf8W3Fb9u8fHO-Oe_c7NpSBC4YNSzkRWu7sspRG45VV1WczKh63AoEz0nsBlDXXBgTccpdQUOr8KDgAevz3utZvTOOG5AqrtnGSbw_r0xtns.mp4',
        ),
        const Restaurant(
          id: 'demo_video_9',
          name: 'Woody One Steak',
          nameAr: 'وودي ون - ستيك',
          category: 'مشويات وبرجر',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=2069',
          rating: 4.9,
          reviewCount: 135,
          deliveryTime: '25-35 دقيقة',
          deliveryFee: 150,
          isOpen: true,
          address: 'الجزائر العاصمة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353060/AQNCKCdeIWaPm8tWV2rFeWTlzmKFjIUh4-bvZP6ywcHVxovJqvNNP8XwBq79ottWDasw2An6WpWdE_tZZM29MLSpas4Mo2wK-UVSQihv_Q_kn4ftc.mp4',
        ),
        const Restaurant(
          id: 'demo_video_10',
          name: 'Dream Restaurant',
          nameAr: 'مطعم الأحلام',
          category: 'أكل سريع',
          type: 'Fast Food',
          imageUrl:
              'https://images.unsplash.com/photo-1512152272829-e3139592d56f?q=80&w=2070',
          rating: 4.7,
          reviewCount: 310,
          deliveryTime: '15-25 دقيقة',
          deliveryFee: 100,
          isOpen: true,
          address: 'بجاية',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353213/AQPPvbaGpzLuwRVadCHpKEwwox9tSGB8PTfZYCe3JBFaoyQZCQnetUngzo7Ufa902YrMI8WWEORofp2NyB7NoQxROp486mKPXFY7doA_q8mkrd.mp4',
        ),
        const Restaurant(
          id: 'demo_video_11',
          name: 'Dream Fast Food',
          nameAr: 'دريم - أكل سريع',
          category: 'أكل سريع',
          type: 'Fast Food',
          imageUrl:
              'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?q=80&w=2071',
          rating: 4.8,
          reviewCount: 190,
          deliveryTime: '15-25 دقيقة',
          deliveryFee: 100,
          isOpen: true,
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353241/AQOcEdyJtrTN3B8Kfaul8GOaIeFyxHm8X2cpXWaHyz5hWN1KX3AFqo1D_ZDm0DIPdMtLwmeUQ-AwUOeR3bFllYRDfH6Wn2EP_dWSu1I_upwd0t.mp4',
          address: '',
        ),
        const Restaurant(
          id: 'demo_video_12',
          name: 'Mardoum Khemis Miliana',
          nameAr: 'مردوم خميس مليانة',
          category: 'تقليدي ومشاوي',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1544124499-58912cbddaad?q=80&w=2070',
          rating: 4.9,
          reviewCount: 520,
          deliveryTime: '30-45 دقيقة',
          deliveryFee: 250,
          isOpen: true,
          address: 'خميس مليانة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353370/AQNgGkIBGrbb9CAQSZJK_Ng5426RUg4LWR3AwjHiQGD-DI_EYYkUrHHWBNLPC5g1e-xbYEy5r3JSky9W6QvY8dIEriBi9YtRG6y85vMJ62wpLg_oaz1rv.mp4',
        ),
        const Restaurant(
          id: 'demo_video_13',
          name: 'Mardoum Special',
          nameAr: 'مردوم - عرض مميز',
          category: 'تقليدي ومشاوي',
          type: 'Restaurant',
          imageUrl:
              'https://images.unsplash.com/photo-1560614382-3334f797b8d4?q=80&w=2070',
          rating: 4.9,
          reviewCount: 215,
          deliveryTime: '30-45 دقيقة',
          deliveryFee: 250,
          isOpen: true,
          address: 'خميس مليانة',
          videoUrl:
              'https://res.cloudinary.com/dlula050a/video/upload/v1778353375/AQNm80lqthqqpU6mEs0syzVm3L8gXX0RCtl_5mSM-RlTiQd12aMWLu2DK_YW62PcnYRAnbgIpWoYUi6si0KPl5NPbYMjuU0gYYBNdDR1H9eiAw_zgyzvq.mp4',
        ),
      ];
    }
    _isLoading = false;
    notifyListeners();
  }

  void refresh() => fetchRestaurants();

  void setType(String type) {
    _selectedType = type;
    _selectedCategory = 'All';
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setWilaya(String wilaya) {
    _selectedWilaya = wilaya;
    notifyListeners();
  }

  List<Restaurant> get filteredRestaurants {
    return _restaurants.where((r) {
      final matchType = _selectedType == 'All' || r.type == _selectedType;
      final matchCat =
          _selectedCategory == 'All' || r.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.nameAr.contains(_searchQuery);
      return matchType && matchCat && matchSearch;
    }).toList();
  }

  int countByType(String type) {
    if (type == 'All') return _restaurants.length;
    return _restaurants.where((r) => r.type == type).length;
  }
}

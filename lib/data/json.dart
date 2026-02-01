// Demo user profile
const String profile = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200";

// Demo user data
const Map<String, dynamic> demoUser = {
  'id': '11111111-1111-1111-1111-111111111111',
  'email': 'georgio@demo.com',
  'full_name': 'Georgio Elias',
  'balance': 860500.00,
  'phone': '+1234567890',
  'is_verified': true,
};

// Recent users for quick transfer
final List<Map<String, String>> recentUsers = [
  {
    "id": "22222222-2222-2222-2222-222222222222",
    "image": "https://images.unsplash.com/photo-1564460576398-ef55d99548b2?w=200",
    "fname": "Niana",
    "lname": "Micky",
    "email": "niana@demo.com",
  },
  {
    "id": "33333333-3333-3333-3333-333333333333",
    "image": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
    "fname": "David",
    "lname": "Villa",
    "email": "david@demo.com",
  },
  {
    "id": "44444444-4444-4444-4444-444444444444",
    "image": "https://images.unsplash.com/photo-1548142813-c348350df52b?w=200",
    "fname": "Lana",
    "lname": "Rose",
    "email": "lana@demo.com",
  },
  {
    "id": "55555555-5555-5555-5555-555555555555",
    "image": "https://images.unsplash.com/photo-1545167622-3a6ac756afa4?w=200",
    "fname": "Joe",
    "lname": "Peter",
    "email": "joe@demo.com",
  },
  {
    "id": "66666666-6666-6666-6666-666666666666",
    "image": "https://images.unsplash.com/photo-1523913507744-1970fd11e9ff?w=200",
    "fname": "James",
    "lname": "Rodri",
    "email": "james@demo.com",
  },
  {
    "id": "77777777-7777-7777-7777-777777777777",
    "image": "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200",
    "fname": "Perl",
    "lname": "Priya",
    "email": "perl@demo.com",
  },
];

// Transactions
final List<Map<String, dynamic>> transactions = [
  {
    "id": "tx1",
    "name": "Niana Micky",
    "image": "https://images.unsplash.com/photo-1564460576398-ef55d99548b2?w=200",
    "price": "\$6,000",
    "amount": 6000.00,
    "type": 0, // 0 = sent, 1 = received
    "category": "Housing",
    "description": "Monthly rent payment",
    "date": "Today, 10:30 AM",
    "status": "completed",
  },
  {
    "id": "tx2",
    "name": "David Villa",
    "image": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
    "price": "\$350",
    "amount": 350.00,
    "type": 1,
    "category": "Food",
    "description": "Lunch money refund",
    "date": "Today, 8:30 AM",
    "status": "completed",
  },
  {
    "id": "tx3",
    "name": "Joe Peter",
    "image": "https://images.unsplash.com/photo-1545167622-3a6ac756afa4?w=200",
    "price": "\$50",
    "amount": 50.00,
    "type": 0,
    "category": "Entertainment",
    "description": "Coffee bet",
    "date": "Today, 6:30 AM",
    "status": "completed",
  },
  {
    "id": "tx4",
    "name": "Salary Deposit",
    "image": "https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=200",
    "price": "\$5,200",
    "amount": 5200.00,
    "type": 1,
    "category": "Income",
    "description": "Salary deposit - January",
    "date": "Yesterday",
    "status": "completed",
  },
  {
    "id": "tx5",
    "name": "Amazon",
    "image": "https://upload.wikimedia.org/wikipedia/commons/a/a9/Amazon_logo.svg",
    "price": "\$89.50",
    "amount": 89.50,
    "type": 0,
    "category": "Shopping",
    "description": "Electronics purchase",
    "date": "Yesterday",
    "status": "completed",
  },
];

// Cards data
final List<Map<String, dynamic>> cards = [
  {
    'id': 'card1',
    'type': 'Visa',
    'number': '**** **** **** 4532',
    'holder': 'GEORGIO ELIAS',
    'expiry': '12/28',
    'balance': 860500.00,
    'color': 0xFF000000,
    'isActive': true,
    'isPrimary': true,
    'dailyLimit': 10000.00,
  },
  {
    'id': 'card2',
    'type': 'Mastercard',
    'number': '**** **** **** 8721',
    'holder': 'GEORGIO ELIAS',
    'expiry': '06/27',
    'balance': 45230.50,
    'color': 0xFF7c62fe,
    'isActive': true,
    'isPrimary': false,
    'dailyLimit': 5000.00,
  },
  {
    'id': 'card3',
    'type': 'Visa',
    'number': '**** **** **** 1234',
    'holder': 'GEORGIO ELIAS',
    'expiry': '03/26',
    'balance': 12500.00,
    'color': 0xFF7ec1fe,
    'isActive': true,
    'isPrimary': false,
    'dailyLimit': 2500.00,
  },
];

// Notifications
final List<Map<String, dynamic>> notifications = [
  {
    'id': 'notif1',
    'title': 'Transfer Successful',
    'message': 'You sent \$6,000 to Niana Micky',
    'type': 'transaction',
    'isRead': false,
    'time': '2 hours ago',
    'icon': 'send',
  },
  {
    'id': 'notif2',
    'title': 'Money Received',
    'message': 'You received \$350 from David Villa',
    'type': 'transaction',
    'isRead': false,
    'time': '4 hours ago',
    'icon': 'receive',
  },
  {
    'id': 'notif3',
    'title': 'Salary Credited',
    'message': 'Your salary of \$5,200 has been deposited',
    'type': 'success',
    'isRead': true,
    'time': '1 day ago',
    'icon': 'deposit',
  },
  {
    'id': 'notif4',
    'title': 'Bill Payment Due',
    'message': 'Your internet bill of \$85 is due tomorrow',
    'type': 'warning',
    'isRead': false,
    'time': '2 days ago',
    'icon': 'warning',
  },
  {
    'id': 'notif5',
    'title': 'Security Alert',
    'message': 'New login from Chrome on MacOS',
    'type': 'info',
    'isRead': true,
    'time': '3 days ago',
    'icon': 'security',
  },
];

// Statistics data
final Map<String, dynamic> statisticsData = {
  'income': 12450.00,
  'expenses': 8230.50,
  'incomeChange': '+15%',
  'expenseChange': '-8%',
  'weeklyData': [
    {'day': 'Mon', 'income': 2500.0, 'expense': 1800.0},
    {'day': 'Tue', 'income': 3200.0, 'expense': 2100.0},
    {'day': 'Wed', 'income': 1800.0, 'expense': 1200.0},
    {'day': 'Thu', 'income': 4200.0, 'expense': 2800.0},
    {'day': 'Fri', 'income': 2800.0, 'expense': 1600.0},
    {'day': 'Sat', 'income': 1500.0, 'expense': 900.0},
    {'day': 'Sun', 'income': 2200.0, 'expense': 1400.0},
  ],
  'categories': [
    {'name': 'Food & Dining', 'amount': 1250.00, 'percentage': 0.35, 'icon': 'restaurant'},
    {'name': 'Shopping', 'amount': 980.00, 'percentage': 0.28, 'icon': 'shopping_bag'},
    {'name': 'Transportation', 'amount': 520.00, 'percentage': 0.15, 'icon': 'directions_car'},
    {'name': 'Entertainment', 'amount': 380.00, 'percentage': 0.11, 'icon': 'movie'},
    {'name': 'Bills & Utilities', 'amount': 320.00, 'percentage': 0.09, 'icon': 'receipt'},
  ],
};

// Bill categories
final List<Map<String, dynamic>> billCategories = [
  {'name': 'Electricity', 'icon': 'bolt', 'color': 0xFFFFCB66, 'provider': 'City Power Co.', 'amount': 120.00, 'dueDate': 'Feb 15'},
  {'name': 'Water', 'icon': 'water_drop', 'color': 0xFF7EC1FE, 'provider': 'Metro Water', 'amount': 45.00, 'dueDate': 'Feb 18'},
  {'name': 'Internet', 'icon': 'wifi', 'color': 0xFFB2E1B5, 'provider': 'FastNet ISP', 'amount': 85.00, 'dueDate': 'Feb 20'},
  {'name': 'Phone', 'icon': 'phone_android', 'color': 0xFFD9BCFF, 'provider': 'Mobile Plus', 'amount': 65.00, 'dueDate': 'Feb 22'},
  {'name': 'Gas', 'icon': 'local_fire_department', 'color': 0xFFF5BDE8, 'provider': 'City Gas', 'amount': 55.00, 'dueDate': 'Feb 25'},
  {'name': 'Insurance', 'icon': 'shield', 'color': 0xFF7C62FE, 'provider': 'SafeGuard Inc.', 'amount': 250.00, 'dueDate': 'Feb 28'},
];

// Quick action services
final List<Map<String, dynamic>> services = [
  {'title': 'Send', 'icon': 'send', 'color': 0xFFB2E1B5},
  {'title': 'Request', 'icon': 'download', 'color': 0xFFFFCB66},
  {'title': 'Pay Bills', 'icon': 'receipt', 'color': 0xFF7C62FE},
  {'title': 'Top Up', 'icon': 'add_card', 'color': 0xFF7EC1FE},
  {'title': 'Scan QR', 'icon': 'qr_code_scanner', 'color': 0xFFF5BDE8},
  {'title': 'More', 'icon': 'widgets', 'color': 0xFFD9BCFF},
];

// Account settings
final List<Map<String, dynamic>> accountSettings = [
  {'title': 'Personal Information', 'icon': 'person_outline', 'route': '/profile'},
  {'title': 'Payment Methods', 'icon': 'credit_card', 'route': '/payment-methods'},
  {'title': 'Notifications', 'icon': 'notifications_outlined', 'route': '/notifications', 'badge': 3},
  {'title': 'Language', 'icon': 'language', 'route': '/language', 'subtitle': 'English'},
];

final List<Map<String, dynamic>> securitySettings = [
  {'title': 'Change Password', 'icon': 'lock_outline', 'route': '/change-password'},
  {'title': 'Biometric Login', 'icon': 'fingerprint', 'route': '/biometric', 'isToggle': true, 'value': true},
  {'title': 'Two-Factor Auth', 'icon': 'security', 'route': '/2fa', 'subtitle': 'Enabled'},
];

final List<Map<String, dynamic>> supportSettings = [
  {'title': 'Help Center', 'icon': 'help_outline', 'route': '/help'},
  {'title': 'Contact Us', 'icon': 'chat_bubble_outline', 'route': '/contact'},
  {'title': 'Privacy Policy', 'icon': 'privacy_tip_outlined', 'route': '/privacy'},
  {'title': 'Terms of Service', 'icon': 'description_outlined', 'route': '/terms'},
];

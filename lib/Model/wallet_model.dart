class WalletModel {
  String? id;
  String? userId;
  String? transactionId;
  String? amount;
  String? createdAt;
  String? modifiedAt;

  WalletModel(
      {this.id,
        this.userId,
        this.transactionId,
        this.amount,
        this.createdAt,
        this.modifiedAt});

  WalletModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    transactionId = json['transaction_id'];
    amount = json['amount'];
    createdAt = json['created_at'];
    modifiedAt = json['modified_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['transaction_id'] = this.transactionId;
    data['amount'] = this.amount;
    data['created_at'] = this.createdAt;
    data['modified_at'] = this.modifiedAt;
    return data;
  }
}

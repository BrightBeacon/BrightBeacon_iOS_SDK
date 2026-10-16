#import "BeaconCell.h"

@implementation BeaconCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _nameLabel.numberOfLines = 0;
        _detailLabel = [UILabel new];
        _detailLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
        _detailLabel.textColor = UIColor.secondaryLabelColor;
        _detailLabel.numberOfLines = 0;
        _signalLabel = [UILabel new];
        _signalLabel.font = [UIFont monospacedDigitSystemFontOfSize:20 weight:UIFontWeightSemibold];
        _signalLabel.textColor = UIColor.systemBlueColor;
        [_signalLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                      forAxis:UILayoutConstraintAxisHorizontal];
        _connectButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_connectButton addTarget:self
                           action:@selector(connect)
                 forControlEvents:UIControlEventTouchUpInside];
        UIStackView *top =
            [[UIStackView alloc] initWithArrangedSubviews:@[ _nameLabel, _signalLabel ]];
        top.spacing = 8;
        top.alignment = UIStackViewAlignmentCenter;
        UIStackView *stack =
            [[UIStackView alloc] initWithArrangedSubviews:@[ top, _detailLabel, _connectButton ]];
        stack.axis = UILayoutConstraintAxisVertical;
        stack.spacing = 10;
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:stack];
        [NSLayoutConstraint activateConstraints:@[
            [stack.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16],
            [stack.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor
                                                constant:16],
            [stack.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor
                                                 constant:-16],
            [stack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-16]
        ]];
    }
    return self;
}

- (void)render:(BRTBeacon *)row ble:(BOOL)ble enabled:(BOOL)enabled {
    self.nameLabel.text =
        ble ? (row.name.length ? row.name : @"未命名设备")
            : [NSString stringWithFormat:@"Major %@ · Minor %@", row.major, row.minor];
    self.detailLabel.text =
        ble ? [NSString stringWithFormat:@"MAC：%@\n本机标识：%@",
                                         row.macAddress.length ? row.macAddress : @"广播未提供",
                                         row.peripheral.identifier.UUIDString ?: @"不可用"]
            : [NSString stringWithFormat:@"UUID：%@", row.proximityUUID.UUIDString ?: @"未知"];
    self.signalLabel.text =
        row.rssi ? [NSString stringWithFormat:@"%ld dBm", (long)row.rssi] : @"RSSI 未知";
    self.connectButton.hidden = !ble;
    self.connectButton.enabled = (row.isBrightBeacon && row.peripheral != nil) && enabled;
    [self.connectButton
        setTitle:(row.isBrightBeacon && row.peripheral != nil) ? @"连接"
                                                               : @"该广播不支持 BrightSDK 连接"
        forState:UIControlStateNormal];
    self.connectButton.accessibilityIdentifier =
        [@"connect-" stringByAppendingString:row.peripheral.identifier.UUIDString ?: @""];
}

- (void)connect {
    if (self.onConnect)
        self.onConnect();
}

@end

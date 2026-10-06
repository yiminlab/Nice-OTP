import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart';
import 'package:two_factor_authentication/services/otp_service.dart';
import 'package:two_factor_authentication/store/otp_token_store.dart';
import '../../api/models/otp_token.dart';
import '../../services/localization_service.dart';
import '../../widgets/qr_scanner.dart';

class AddTab extends StatefulWidget {
  final Function(OTPToken) onAccountAdded;
  final Function() onAccountDeleteAll;

  const AddTab({
    super.key,
    required this.onAccountAdded,
    required this.onAccountDeleteAll,
  });

  @override
  State<AddTab> createState() => _AddTabState();
}

class _AddTabState extends State<AddTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _secretController = TextEditingController();
  final _issuerController = TextEditingController();
  final _urlController = TextEditingController();
  bool _isUrlMode = true;
  final OTPTokenStore _otpTokenStore = OTPTokenStore();

  @override
  void dispose() {
    _nameController.dispose();
    _secretController.dispose();
    _issuerController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    final l10n = LocalizationService.of(context);

    try {
      // ignore: prefer_typing_uninitialized_variables
      var qrCode;

      if (kIsMPFlutterWechat || kIsMPFlutter || kIsMPFlutterDevmode) {
        final completer = Completer<String>();
        wx.scanCode(ScanCodeOption()
          ..success = (result) {
            qrCode = result.result;
            completer.complete(qrCode);
          });
        qrCode = await completer.future;
      } else {
        qrCode = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QRScanner(),
          ),
        );
      }
      if (qrCode != null) {
        setState(() {
          _isUrlMode = true;
          _urlController.text = qrCode;
          final account = OTPToken.fromUri(Uri.parse(qrCode));
          _nameController.text = account.name;
          _secretController.text = account.secret;
          _issuerController.text = account.issuer ?? '';
        });
        _handleSubmit();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.translate('invalid_url')}: $e'),
        ),
      );
    }
  }

  void _handleSubmit() {
    final l10n = LocalizationService.of(context);

    if (_formKey.currentState!.validate()) {
      if (_isUrlMode) {
        try {
          final account = OTPToken.fromUri(Uri.parse(_urlController.text));
          widget.onAccountAdded(account);
          _clearInputs();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('invalid_url')),
            ),
          );
        }
      } else {
        widget.onAccountAdded(
          OTPToken(
            name: _nameController.text,
            secret: _secretController.text,
            issuer: _issuerController.text,
          ),
        );
        _clearInputs();
      }
    }
  }

  void _clearInputs() {
    setState(() {
      _urlController.clear();
      _nameController.clear();
      _secretController.clear();
      _issuerController.clear();
    });
  }

  Future<bool> _checkAccountLimit() async {
    final l10n = LocalizationService.of(context);

    if (_otpTokenStore.canAddMoreTokens == false) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('account_limit_reached')),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _addRandomAccount() async {
    if (_otpTokenStore.canAddMoreTokens == true) {
      final account = OTPService.addRandomAccount();
      widget.onAccountAdded(account);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationService.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.translate('by_key_url')),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.translate('by_secret_key')),
                  ),
                ],
                selected: {_isUrlMode},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isUrlMode = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_isUrlMode)
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('url'),
                    hintText: l10n.translate('enter_url'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.translate('please_enter_url');
                    }
                    if (!value.startsWith('otpauth://')) {
                      return l10n.translate('invalid_url');
                    }
                    return null;
                  },
                  onChanged: (url) {
                    if (url.startsWith('otpauth://')) {
                      try {
                        final account = OTPToken.fromUri(Uri.parse(url));
                        setState(() {
                          _nameController.text = account.name;
                          _secretController.text = account.secret;
                          _issuerController.text = account.issuer ?? '';
                        });
                      } catch (e) {
                        // Invalid URL format, ignore
                      }
                    }
                  },
                )
              else
                Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.translate('account_name'),
                        hintText: l10n.translate('enter_account_name'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.translate('please_enter_account');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _secretController,
                      decoration: InputDecoration(
                        labelText: l10n.translate('secret_key'),
                        hintText: l10n.translate('enter_secret_key'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.translate('please_enter_secret');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _issuerController,
                      decoration: InputDecoration(
                        labelText: l10n.translate('issuer'),
                        hintText: l10n.translate('enter_issuer'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _scanQRCode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(l10n.translate('scan_qr_code')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        if (await _checkAccountLimit()) {
                          _handleSubmit();
                        }
                      },
                      label: Text(l10n.translate('add_account')),
                    ),
                  ),
                ],
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (await _checkAccountLimit()) {
                            await _addRandomAccount();
                          }
                        },
                        icon: const Icon(Icons.shuffle),
                        label: Text(l10n.translate('add_random_account')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.translate('clear_all_accounts')),
                              content: Text(
                                  l10n.translate('clear_all_accounts_confirm')),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(l10n.translate('cancel')),
                                ),
                                TextButton(
                                  onPressed: () {
                                    widget.onAccountDeleteAll();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            l10n.translate('accounts_cleared')),
                                      ),
                                    );
                                  },
                                  child: Text(l10n.translate('clear')),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_forever),
                        label: Text(l10n.translate('clear_all_accounts')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qtech_task/core/extensions/extensions.dart';


import 'custom_image.dart';

// import 'select_item_sheet.dart';

class AppInput extends StatefulWidget {
  final String? hintText, labelText, errorText, prefixPath;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry? margin;
  final String? Function(String?)? validator;
  final bool isRequired, isDropDown, loading;
  final InputBorder? border;
  final int? maxLines;
  final void Function(String val)? onChanged;
  final void Function()? onTap;
  final Widget? suffixIcon, prefixIcon, labelSuffix;
  final Color? fillColor, labelColor;
  final TextStyle? hintStyle;
  final TextInputAction textInputAction;
  final int? constLength;

  const AppInput({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.keyboardType,
    this.margin,
    this.validator,
    this.isRequired = true,
    this.loading = false,
    this.isDropDown = false,
    this.onTap,
    this.onChanged,
    this.maxLines,
    this.suffixIcon,
    this.labelSuffix,
    this.hintStyle,
    this.fillColor,
    this.prefixIcon,
    this.prefixPath,
    this.labelColor,
    this.errorText,
    this.constLength,
    this.border,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool isHidden = true;

  // late CountryModel country = widget.initCountry ??
  //     CountryModel.fromJson(jsonDecode(Prefs.getString('country') ?? "{}"));
  // late final CountriesBloc countryBloc;

  // @override
  // void initState() {
  //   if (widget.keyboardType == TextInputType.phone) {
  //     countryBloc = sl<CountriesBloc>()..add(StartCountriesEvent(false));
  //     if (country.phoneCode.isNotEmpty) {
  //       widget.onChangeCountry?.call(country);
  //       setState(() {});
  //     }
  //   }
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? EdgeInsets.only(top: 10),
      child: TextFormField(
        maxLength: widget.keyboardType == TextInputType.phone ? 9 : null,
        onChanged: widget.onChanged,
        maxLines: widget.maxLines,
        textInputAction: widget.textInputAction,
        readOnly: widget.onTap != null,
        onTap: widget.onTap,
        obscureText:
            widget.keyboardType == TextInputType.visiblePassword && isHidden,
        cursorColor: context.primaryColorLight,
        style: TextStyle(
          fontSize: 15,
          color: context.primaryColorLight,
          fontWeight: FontWeight.w500,
        ),
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        validator: (v) {
          if (widget.isRequired && v?.isEmpty == true) {
            return "this field is required";
          } else if (widget.keyboardType == TextInputType.phone &&
              v!.length < 8) {
            return "the phone number must consist of 8 numbers";
          } else if (widget.keyboardType == TextInputType.visiblePassword &&
              v!.length < 8) {
            return "the password must not be less than 8 numbers";
          } else if (widget.constLength != null &&
              v!.length != widget.constLength) {
            return "the length must be ${widget.constLength}";
          } else if (widget.validator != null) {
            return widget.validator?.call(v);
          }
          return null;


          //    if (widget.isRequired && v?.isEmpty == true) {
          //   return LocaleKeys.val_is_required.tr(
          //     args: [
          //       widget.labelText?.replaceAll('*', '') ??
          //           LocaleKeys.this_field.tr(),
          //     ],
          //   );
          // } else if (widget.keyboardType == TextInputType.phone &&
          //     v!.length < 8) {
          //   return LocaleKeys.the_phone_number_must_consist_of_val_numbers.tr();
          // } else if (widget.keyboardType == TextInputType.emailAddress) {
          //   return InputValidator.emailValidator(v!);
          // } else if (widget.keyboardType == TextInputType.visiblePassword &&
          //     v!.length < 8) {
          //   return LocaleKeys.the_password_must_not_be_less_than_8_numbers.tr();
          // } else if (widget.constLength != null &&
          //     v!.length != widget.constLength) {
          //   return LocaleKeys.validate_const_length.tr(
          //     args: [widget.labelText ?? '', widget.constLength.toString()],
          //   );
          // } else if (widget.validator != null) {
          //   return widget.validator?.call(v);
          // }
          // return null;
        },
        inputFormatters: [
          if (widget.keyboardType == TextInputType.number)
            FilteringTextInputFormatter.digitsOnly,
          if (widget.keyboardType == TextInputType.phone)
            LengthLimitingTextInputFormatter(9),
          if (widget.constLength != null)
            LengthLimitingTextInputFormatter(widget.constLength),
        ],
        decoration: InputDecoration(
          hintStyle: widget.hintStyle,
          hintText: widget.hintText,
          labelText: widget.labelText,
          errorMaxLines: 2,
          errorText: widget.errorText,
          fillColor: widget.fillColor,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border:
              widget.border ??
              OutlineInputBorder(
                borderSide: BorderSide(color: context.borderColor),
                borderRadius: BorderRadius.circular(14),
              ),
          disabledBorder:
              widget.border ??
              OutlineInputBorder(
                borderSide: BorderSide(color: context.borderColor),
                borderRadius: BorderRadius.circular(14),
              ),
          enabledBorder:
              widget.border ??
              OutlineInputBorder(
                borderSide: BorderSide(color: '#F2F2F2'.color),
                borderRadius: BorderRadius.circular(14),
              ),
          focusedBorder:
              widget.border ??
              OutlineInputBorder(
                borderSide: BorderSide(color: context.primaryColor),
                borderRadius: BorderRadius.circular(14),
              ),
          prefixIcon: widget.prefixIcon ??
              (widget.prefixPath != null
                  ? CustomImage(
                      widget.prefixPath!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ).paddingAll(all: 12)
                  : null),
        ),
      ),
    );
  }


    // else if (widget.keyboardType == TextInputType.phone) {
    //   return BlocConsumer<CountriesBloc, CountriesState>(
    //       bloc: countryBloc,
    //       listener: (context, state) {
    //         if (state.state.isError) {
    //           FlashHelper.showToast(state.msg);
    //         } else if (state.state.isDone) {
    //           if (state.openSheet) {
    //             showModalBottomSheet<CountryModel?>(
    //               context: context,
    //               builder: (context) => SelectItemSheet(
    //                   title: LocaleKeys.select_val
    //                       .tr(args: [LocaleKeys.country_code.tr()]),
    //                   items: state.data,
    //                   initItem: country,
    //                   withImage: true),
    //             ).then((value) {
    //               if (value != null) {
    //                 country = value;
    //                 Prefs.setString('country', jsonEncode(country.toJson()));

    //                 widget.onChangeCountry?.call(country);
    //                 setState(() {});
    //               }
    //             });
    //           } else if (country.phoneCode.isEmpty && state.data.isNotEmpty) {
    //             country = state.data.first;
    //             widget.onChangeCountry?.call(country);
    //             setState(() {});
    //           } else if (country.phoneCode.isNotEmpty &&
    //               state.data.isNotEmpty &&
    //               country.image.isEmpty) {
    //             int i = state.data.indexWhere(
    //               (element) => element.phoneCode == country.phoneCode,
    //             );
    //             if (i != -1) {
    //               country = state.data[i];
    //             }
    //             widget.onChangeCountry?.call(country);
    //             setState(() {});
    //           }
    //         }
    //       },
    //       builder: (context, state) => InkWell(
    //           onTap: () {
    //             if (!state.state.isLoading) {
    //               countryBloc.add(StartCountriesEvent(true));
    //             }
    //           },
    //           child: Row(mainAxisSize: MainAxisSize.min, children: [
    //             CustomImage(country.image,
    //                     borderRadius: BorderRadius.circular(2.r),
    //                     height: 14.h,
    //                     width: 21.w,
    //                     fit: BoxFit.fill)
    //                 .paddingAll(start: 20.w, end: 4.w),
    //             Text("+${country.phoneCode}",
    //                 style: context.regularText.copyWith(
    //                     fontSize: 12, color: context.primaryColorLight),
    //                 textDirection: TextDirection.ltr),
    //             const Icon(Icons.keyboard_arrow_down_outlined)
    //                 .paddingAll(start: 4.w, end: 8.w),
    //             Container(
    //                 margin: EdgeInsetsDirectional.only(end: 10.w),
    //                 height: 50.h,
    //                 width: .3,
    //                 color: context.hintColor)
    //           ])));
    // }
  
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_cubit.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_state.dart';

/// Lets a servant/admin bulk-create students by uploading an Excel sheet,
/// with a template download so they know the expected column layout.
class StudentsExcelUploadScreen extends StatefulWidget {
  const StudentsExcelUploadScreen({super.key});

  @override
  State<StudentsExcelUploadScreen> createState() =>
      _StudentsExcelUploadScreenState();
}

class _StudentsExcelUploadScreenState extends State<StudentsExcelUploadScreen> {
  PlatformFile? _pickedFile;
  bool _isBusy = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => _pickedFile = result.files.first);
  }

  void _clearFile() => setState(() => _pickedFile = null);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeLoadingState) {
            showLoadingDialog(context);
          }

          if (state is HomeSuccessState) {
            pop(context); // Close the loading dialog
            showMyDialoge(
              context,
              state.message ?? "تم رفع الملف بنجاح.",
              type: DialogType.success,
            );
            setState(() => _pickedFile = null);
          } else if (state is HomeErrorState) {
            showMyDialoge(context, state.message, type: DialogType.error);
          } else if (state is HomeExcelTemplateDownloadSuccessState) {
            showMyDialoge(
              context,
              state.message ?? "تم حفظ الملف بنجاح.",
              type: DialogType.success,
            );
          }
        },

        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 16,
                  20,
                  24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.upload_file_rounded,
                        color: AppColors.darkYellowIconColor,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      'رفع بيانات المخدومين',
                      style: TextStyles.getSize24(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Template download card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.description_rounded,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'نموذج ملف Excel',
                                    style: TextStyles.getSize16(
                                      color: AppColors.accentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    'حمّل النموذج لمعرفة أسماء الأعمدة وطريقة إدخال البيانات',
                                    style: TextStyles.getSize12(
                                      color: AppColors.accentColor.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isBusy
                              ? null
                              : () => context
                                    .read<HomeCubit>()
                                    .downloadExcelTemplate(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(
                            Icons.download_rounded,
                            color: AppColors.primaryColor,
                          ),
                          label: Text(
                            'تحميل نموذج Excel',
                            style: TextStyles.getSize16(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const Gap(28),
                      Text(
                        'رفع الملف',
                        style: TextStyles.getSize16(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(10),

                      // Upload area
                      GestureDetector(
                        onTap: _isBusy ? null : _pickFile,
                        child: DottedUploadArea(
                          pickedFile: _pickedFile,
                          onClear: _isBusy ? null : _clearFile,
                        ),
                      ),

                      const Gap(20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_pickedFile == null || _isBusy)
                              ? null
                              : () {
                                  final bytes = _pickedFile!.bytes;
                                  if (bytes == null) return;
                                  context
                                      .read<HomeCubit>()
                                      .importStudentsFromExcel(bytes);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            disabledBackgroundColor: AppColors.primaryColor
                                .withValues(alpha: 0.3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isBusy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.whiteColor,
                                  ),
                                )
                              : Text(
                                  'رفع البيانات',
                                  style: TextStyles.getSize16(
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const Gap(16),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: AppColors.accentColor.withValues(alpha: 0.4),
                          ),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              'تأكد من استخدام نفس ترتيب وأسماء الأعمدة الموجودة في النموذج',
                              style: TextStyles.getSize12(
                                color: AppColors.accentColor.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Tap target that shows an upload prompt, or the picked file's name
/// with a clear (x) button once one is selected.
class DottedUploadArea extends StatelessWidget {
  const DottedUploadArea({
    super.key,
    required this.pickedFile,
    required this.onClear,
  });

  final PlatformFile? pickedFile;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasFile = pickedFile != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: hasFile
            ? AppColors.primaryColor.withValues(alpha: 0.05)
            : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: hasFile ? 0.3 : 0.15),
          width: 1.4,
        ),
      ),
      child: hasFile
          ? Row(
              children: [
                const Icon(
                  Icons.table_chart_rounded,
                  color: AppColors.primaryColor,
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    pickedFile!.name,
                    style: TextStyles.getSize16(
                      color: AppColors.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onClear != null)
                  IconButton(
                    onPressed: onClear,
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.accentColor.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            )
          : Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: AppColors.primaryColor.withValues(alpha: 0.5),
                ),
                const Gap(10),
                Text(
                  'اضغط لاختيار ملف Excel',
                  style: TextStyles.getSize16(
                    color: AppColors.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                Text(
                  '.xlsx فقط',
                  style: TextStyles.getSize12(
                    color: AppColors.accentColor.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
    );
  }
}

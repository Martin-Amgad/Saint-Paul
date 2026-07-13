const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onMissionCreated = functions.firestore
    .document('Mission/{missionId}')
    .onCreate(async (snap, context) => {
        const mission = snap.data();
        const teacherId = mission.createdBy;                // ← now required
        const targetType = mission.targetType || 'missionFields'; // default to using mission's own fields

        // 1. Teacher name
        let teacherName = 'خادم';
        if (teacherId) {
            const teacherDoc = await admin.firestore()
                .collection('Teacher')
                .doc(teacherId)
                .get();
            if (teacherDoc.exists) {
                teacherName = teacherDoc.data().name || 'خادم';
            }
        }

        let uids = [];

        // ------- NEW MODE: Use the mission's own church/family/studyLevel -------
        if (targetType === 'missionFields') {
            const church = mission.missionChurch;
            const family = mission.missionFamily;
            const studyLevel = mission.missionStudyLevel;

            if (!church || !family) return null;   // minimum required

            let query = admin.firestore()
                .collection('Student')
                .where('church', '==', church)
                .where('family', '==', family);

            // If studyLevel is not "الكل", filter by it
            if (studyLevel && studyLevel !== 'الكل') {
                query = query.where('studyLevel', '==', studyLevel);
            }

            const studentsSnap = await query.select('uid').get();
            uids = studentsSnap.docs.map(doc => doc.data().uid);
        }

        // ------- (You can still keep the other modes if you want) -------
        // else if (targetType === 'teacherScope') {
        //     ... original teacherScope code (unchanged)
        //     but make sure to use mission.church or mission.missionChurch
        // }
        // else if (targetType === 'familyAndLevel') {
        //     ... original familyAndLevel code
        // }
        // else if (targetType === 'specificStudents') {
        //     uids = mission.assignedStudentIds || [];
        // }

        if (uids.length === 0) return null;

        // 2. Fetch tokens
        const tokenDocs = await admin.firestore()
            .collection('fcmTokens')
            .where('uid', 'in', uids)
            .get();
        const tokens = tokenDocs.docs.map(doc => doc.data().token);
        if (tokens.length === 0) return null;

        // 3. Send notification
        const payload = {
            notification: {
                title: `📋 ${mission.title || 'مهمة جديدة'}`,
                body: `${teacherName} أضاف مهمة: ${mission.description || ''}`,
            },
            data: {
                type: 'new_mission',
                missionId: context.params.missionId,
            },
            tokens: tokens,
        };

        try {
            const response = await admin.messaging().sendEachForMulticast(payload);
            console.log(`✅ Notification sent to ${response.successCount} devices`);
        } catch (error) {
            console.error('❌ Error sending notification:', error);
        }
    });
import { Call } from '../../models/call_model.js';

export const getCalls = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const skip = (page - 1) * limit;
        const sort = req.query.sort === 'asc' ? 1 : -1; // 1 for asc, -1 for desc
        const search = req.query.search || '';
        const statusFilter = req.query.status; // 'missed', 'received', or undefined

        let query = {};

        if (statusFilter) {
            query.status = statusFilter;
        }

        const callsQuery = Call.find(query);

        if (search) {
            const userSearchCondition = {
                $or: [
                    { username: { $regex: search, $options: 'i' } },
                    { email: { $regex: search, $options: 'i' } }
                ]
            };

            // Apply the search condition within populate options
            callsQuery.populate({
                path: 'callerId',
                match: userSearchCondition,
                select: 'username email profilePic'
            }).populate({
                path: 'receiverId',
                match: userSearchCondition,
                select: 'username email profilePic'
            });
        } else {
            // If no search term, just populate without matching
            callsQuery.populate('callerId', 'username email profilePic');
            callsQuery.populate('receiverId', 'username email profilePic');
        }

        const calls = await callsQuery
            .skip(skip)
            .limit(limit)
            .sort({ startedAt: sort });

        const total = await Call.countDocuments(query);

        // Filter out calls where populated fields didn't match the search (if search was applied)
        const filteredCalls = search ? calls.filter(call => call.callerId !== null || call.receiverId !== null) : calls;

        res.status(200).json({
            calls: filteredCalls,
            pagination: {
                total,
                page,
                pages: Math.ceil(total / limit)
            }
        });
    } catch (error) {
        console.error('Get calls error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

export const deleteCall = async (req, res) => {
    try {
        const { callId } = req.params;

        const call = await Call.findById(callId);
        if (!call) {
            return res.status(404).json({
                success: false,
                message: 'Call not found'
            });
        }

        await Call.deleteOne({ _id: callId });

        res.status(200).json({
            success: true,
            message: 'Call deleted successfully'
        });
    } catch (error) {
        console.error('Delete call error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error',
            error: error.message
        });
    }
};

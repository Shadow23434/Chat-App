import { Support } from '../../models/support_model.js';

/**
 * Lấy danh sách tất cả ticket hỗ trợ
 */
export const getSupport = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const status = req.query.status || 'all';

        let query = {};
        if (status !== 'all') {
            query.status = status;
        }

        const supports = await Support.find(query)
            .populate('userId', 'username email profilePic')
            .skip(skip)
            .limit(limit)
            .sort({ updatedAt: -1 });

        const total = await Support.countDocuments(query);

        res.status(200).json({
            supports,
            pagination: {
                total,
                page,
                pages: Math.ceil(total / limit)
            }
        });
    } catch (error) {
        console.error('Get support error:', error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

/**
 * Lấy thông tin chi tiết của một ticket hỗ trợ
 */
export const getSupportDetails = async (req, res) => {
    try {
        const { ticketId } = req.params;

        const support = await Support.findById(ticketId)
            .populate('userId', 'username email profilePic')
            .populate('responses.adminId', 'username');

        if (!support) {
            return res.status(404).json({ message: 'Không tìm thấy ticket hỗ trợ' });
        }

        res.status(200).json({ support });
    } catch (error) {
        console.error('Get support details error:', error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

/**
 * Phản hồi một ticket hỗ trợ
 */
export const respondToSupport = async (req, res) => {
    try {
        const { ticketId } = req.params;
        const { response } = req.body;

        const support = await Support.findById(ticketId);
        if (!support) {
            return res.status(404).json({ message: 'Không tìm thấy ticket hỗ trợ' });
        }

        // Thêm phản hồi vào ticket
        support.responses.push({
            adminId: req.userId,
            message: response,
            createdAt: new Date()
        });

        // Cập nhật trạng thái
        support.status = 'answered';

        await support.save();

        res.status(200).json({
            message: 'Đã thêm phản hồi thành công',
            support
        });
    } catch (error) {
        console.error('Respond to support error:', error);
        res.status(500).json({ message: 'Lỗi server' });
    }
}; 
/**
 * Middleware để kiểm tra quyền truy cập cho các route
 * @param {string} permission - Tên quyền cần kiểm tra (ví dụ: 'admin:users:read')
 * @returns {Function} Middleware Express
 */
export const checkPermission = (permission) => {
    return (req, res, next) => {
        // Super admin có tất cả các quyền
        if (req.userRole === 'super_admin') {
            return next();
        }

        // Kiểm tra nếu user có quyền cụ thể
        if (!req.permissions || !req.permissions.get(permission)) {
            return res.status(403).json({
                success: false,
                message: 'Không đủ quyền thực hiện chức năng này',
            });
        }

        next();
    };
};

/**
 * Middleware kiểm tra nhiều quyền (cần có tất cả các quyền liệt kê)
 * @param {Array<string>} permissions - Danh sách quyền cần kiểm tra
 * @returns {Function} Middleware Express
 */
export const checkAllPermissions = (permissions) => {
    return (req, res, next) => {
        // Super admin có tất cả các quyền
        if (req.userRole === 'super_admin') {
            return next();
        }

        // Kiểm tra tất cả quyền được yêu cầu
        const hasAllPermissions = permissions.every(permission =>
            req.permissions && req.permissions.get(permission)
        );

        if (!hasAllPermissions) {
            return res.status(403).json({
                success: false,
                message: 'Không đủ quyền thực hiện chức năng này',
            });
        }

        next();
    };
};

/**
 * Middleware kiểm tra bất kỳ quyền nào (chỉ cần có một trong các quyền liệt kê)
 * @param {Array<string>} permissions - Danh sách quyền cần kiểm tra
 * @returns {Function} Middleware Express
 */
export const checkAnyPermission = (permissions) => {
    return (req, res, next) => {
        // Super admin có tất cả các quyền
        if (req.userRole === 'super_admin') {
            return next();
        }

        // Kiểm tra bất kỳ quyền nào được yêu cầu
        const hasAnyPermission = permissions.some(permission =>
            req.permissions && req.permissions.get(permission)
        );

        if (!hasAnyPermission) {
            return res.status(403).json({
                success: false,
                message: 'Không đủ quyền thực hiện chức năng này',
            });
        }

        next();
    };
}; 
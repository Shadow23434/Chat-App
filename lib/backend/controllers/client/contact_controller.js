import { Contact } from '../../models/contact_model.js';
import { User } from '../../models/user_model.js';

export const getContact = async (req, res) => {
    try {
        const userId = req.userId;
        const contacts = await Contact.find({
            $or: [
                { userId1: userId },
                { userId2: userId }
            ],
            status: { $in: ['accepted', 'pending'] }
        })
            .populate('userId1', 'username profilePic email')
            .populate('userId2', 'username profilePic email');

        const grouped = { accepted: [], pending: [] };
        contacts.forEach(contact => {
            const otherUser = contact.userId1._id.toString() === userId.toString() ? contact.userId2 : contact.userId1;
            const contactObj = {
                contactId: contact._id,
                userId: otherUser._id,
                username: otherUser.username,
                profilePic: otherUser.profilePic,
                email: otherUser.email,
                status: contact.status
            };
            if (contact.status === 'accepted') {
                grouped.accepted.push(contactObj);
            } else if (
                contact.status === 'pending' &&
                contact.userId2._id.toString() === userId.toString()
            ) {
                grouped.pending.push(contactObj);
            }
        });

        res.json(grouped);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch contacts' });
    }
};

export const addContact = async (req, res) => {
    const userId = req.userId;
    const { email } = req.body;

    try {
        const otherUser = await User.findOne({ email });
        if (!otherUser) {
            return res.status(400).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        if (userId === otherUser.id) {
            return res.status(400).json({ error: 'Cannot add yourself as a contact' });
        }

        const existingContact = await Contact.findOne({
            $or: [
                { userId1: userId, userId2: otherUser.id },
                { userId1: otherUser.id, userId2: userId }
            ]
        });

        if (existingContact) {
            return res.status(400).json({ error: 'Contact relationship already exists' });
        }

        const newContact = new Contact({
            userId1: userId,
            userId2: otherUser.id,
            status: 'pending'
        });

        await newContact.save();
        res.status(201).json({ message: 'Contact request sent', contact: newContact });
    } catch (error) {
        res.status(500).json({ error: 'Failed to add contact' });
    }
};

export const acceptContact = async (req, res) => {
    const userId = req.userId;
    const { contactId } = req.params;

    try {
        const contact = await Contact.findById(contactId);
        if (!contact) {
            return res.status(404).json({ error: 'Contact request not found' });
        }

        if (contact.userId2.toString() !== userId.toString()) {
            return res.status(403).json({ error: 'Not authorized to accept this contact request' });
        }

        if (contact.status !== 'pending') {
            return res.status(400).json({ error: 'Contact request is not pending' });
        }

        const updatedContact = await Contact.findByIdAndUpdate(
            contactId,
            { status: 'accepted' },
            { new: true }
        );

        res.status(200).json({ message: 'Contact request accepted', contact: updatedContact });
    } catch (error) {
        res.status(500).json({ error: 'Failed to accept contact request' });
    }
};

export const deleteContact = async (req, res) => {
    const userId = req.userId;
    const { contactId } = req.params;

    try {
        const contact = await Contact.findById(contactId);
        if (!contact) {
            return res.status(404).json({ error: 'Contact not found' });
        }

        if (contact.userId1.toString() !== userId.toString() && contact.userId2.toString() !== userId.toString()) {
            return res.status(403).json({ error: 'Not authorized to delete this contact' });
        }

        await Contact.findByIdAndDelete(contactId);
        res.status(200).json({ message: 'Contact deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete contact' });
    }
};

class User < ApplicationRecord
  include UserRoles

  validates :email, uniqueness: true, presence: true
  validates :name, presence: true
  validates :phone, uniqueness: true, presence: true
  validates :role, inclusion: { in: ROLES }
  validates :timezone, presence: true, inclusion: { in: TZInfo::Timezone.all_identifiers,
                                                    message: "This is not a valid timezone" }
  has_one :coach_profile, dependent: :destroy
end

require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @request.headers["accept"] = "application/json"
    @current_user = create(:user)
    sign_in @current_user
    @campaign = create(:campaign, user: @current_user)
  end

  describe "POST #create" do
    context "with valid attributes" do
      before { @member_attributes = attributes_for(:member, campaign_id: @campaign.id) }

      it "returns http success" do
        post :create, params: { member: @member_attributes }
        expect(response).to have_http_status :success
      end

      it "add a new member" do
        expect {
          post :create, params: { member: @member_attributes }
        }.to change(Member, :count).by(1)
      end
    end

    context "with invalid attributes" do
      before { @member_attributes = attributes_for(:member, name: nil, campaign_id: @campaign.id) }

      it "returns http unprocessable entity" do
        post :create, params: { member: @member_attributes }
        expect(response).to have_http_status :unprocessable_entity
      end

      it "doesn't add a new member" do
        expect {
          post :create, params: { member: @member_attributes }
        }.to_not change(Member, :count)
      end
    end
  end

  describe "PATCH #update" do
    context "when is campaign owner" do
      context "with valid attributes" do
        before { @member = create(:member, campaign_id: @campaign.id) }

        it "returns http success" do
          patch :update, params: { id: @member.id, member: { name: "New name" } }
          expect(response).to have_http_status :success
        end

        it "change member attribute" do
          patch :update, params: { id: @member.id, member: { name: "New name" } }
          @member.reload
          expect(@member.name).to eq "New name"
        end
      end

      context "with invalid attributes" do
        before { @member = create(:member, campaign_id: @campaign.id) }

        it "returns http unprocessable_entity" do
          patch :update, params: { id: @member.id, member: { name: nil } }
          expect(response).to have_http_status :unprocessable_entity
        end

        it "doesn't change member attribute" do
          old_name = @member.name
          patch :update, params: { id: @member.id, member: { name: nil } }
          @member.reload
          expect(@member.name).to eq old_name
        end
      end
    end

    context "when isn't campaign owner" do
      it "returns forbidden status" do
        campaign = create(:campaign)
        member = create(:member, campaign_id: campaign.id)
        patch :update, params: { id: member.id, member: { name: "New name" } }
        expect(response).to have_http_status :forbidden
      end
    end
  end

  describe "GET #destroy" do
    context "when is campaign owner" do
      before { @member = create(:member, campaign_id: @campaign.id) }

      it "returns http success" do
        delete :destroy, params: { id: @member.id }
        expect(response).to have_http_status :success
      end

      it "remove Member" do
        expect {
          delete :destroy, params: { id: @member.id }
        }.to change(Member, :count).by(-1)
      end
    end

    context "when isn't campaign owner" do
      it "returns forbidden status" do
        campaign = create(:campaign)
        member = create(:member, campaign_id: campaign.id)
        delete :destroy, params: { id: member.id }
        expect(response).to have_http_status :forbidden
      end
    end
  end
end
